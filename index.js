const { execSync } = require('child_process');

// Fungsi untuk menjalankan perintah `rails server` secara sinkron
function startRailsServer() {
  try {
    console.log('Memulai server Ruby on Rails...');
    execSync('rails server -b 0.0.0.0', { stdio: 'inherit' });
  } catch (error) {
    console.error('Terjadi kesalahan saat memulai server Ruby on Rails:', error);
    process.exit(1);
  }
}

// Memanggil fungsi untuk menjalankan server
startRailsServer();
