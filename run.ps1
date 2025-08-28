Write-Host "🔍 Mengecek apakah new_koperasi_apps.exe masih jalan..."

# Kill proses lama kalau ada
$process = Get-Process "new_koperasi_apps" -ErrorAction SilentlyContinue
if ($process) {
    Write-Host "⚡ Menutup proses lama..."
    Stop-Process -Name "new_koperasi_apps" -Force
    Start-Sleep -Seconds 1
} else {
    Write-Host "✅ Tidak ada proses lama."
}

# Optional: bersihin build lama
Write-Host "🧹 Membersihkan build lama..."
flutter clean

# Ambil dependency terbaru
Write-Host "📦 Mendapatkan dependency..."
flutter pub get

# Run app di Windows
Write-Host "🚀 Menjalankan aplikasi Flutter di Windows..."
flutter run -d windows
