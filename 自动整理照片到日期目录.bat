@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo 正在按EXIF拍摄日期整理照片（剪切操作）...
echo 请确保已安装 ExifTool 并配置系统环境变量！

for %%i in (*.jpg *.jpeg *.png *.heic) do (
    set "file=%%i"
    set "taken_date="

    :: 使用ExifTool提取EXIF拍摄日期（标签DateTimeOriginal）
    for /f "tokens=1-3 delims=: " %%a in ('exiftool -DateTimeOriginal -S -s "%%i"') do (
        set "year=%%a"
        set "month=%%b"
        set "day=%%c"
    )

    :: 若未获取到EXIF日期，则使用文件修改日期（降级处理）
    if "!year!"=="" (
        for /f "tokens=1-3 delims=/ " %%a in ("%%~ti") do (
            set "year=%%a"
            set "month=%%b"
            set "day=%%c"
        )
    )

    :: 去除月份/日期的前导零（如07→7）
    if "!month:~0,1!"=="0" set "month=!month:~1!"
    if "!day:~0,1!"=="0" set "day=!day:~1!"

    :: 构建目标文件夹名（格式：2023年12月5日）
    set "folder_name=!year!年!month!月!day!日"

    :: 创建文件夹并移动文件
    if not exist "!folder_name!" (
        md "!folder_name!"
        echo 创建文件夹: !folder_name!
    )
    move "%%i" "!folder_name!\" >nul
    echo 剪切: %%i → !folder_name!
)
echo 整理完成！所有照片已按拍摄日期剪切至对应文件夹。
pause