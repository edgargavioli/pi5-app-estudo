const { createCanvas, loadImage, registerFont } = require('canvas');
const path = require('path');

// Register Montserrat variable font for use in canvas
registerFont(
  path.join(__dirname, '../assets/fonts/Montserrat/Montserrat-VariableFont_wght.ttf'),
  { family: 'Montserrat' }
);

class CanvasService {
  /**
   * Generates a wrapped image by drawing on a provided background image buffer
   * @param {Buffer} backgroundBuffer - The background image buffer
   * @param {Object} user - User data ({ id, name, email, points, createdAt })
   * @param {Object} stats - Aggregated study statistics
   * @returns {Buffer} PNG image buffer
   */
  async generateWrappedImage(backgroundBuffer, user, stats) {
    // Load and draw the background image
    const img = await loadImage(backgroundBuffer);
    const canvas = createCanvas(img.width, img.height);
    const ctx = canvas.getContext('2d');
    ctx.drawImage(img, 0, 0);

    // Header text at the top
    ctx.fillStyle = '#ffffff';
    ctx.font = '32px "Montserrat"';
    ctx.textAlign = 'center';
    ctx.fillText(
      'A dedicação no aprendizado define o seu resultado.',
      canvas.width / 2,
      60
    );

    // Left-middle stats list
    ctx.font = '24px "Montserrat"';
    ctx.textAlign = 'left';
    // Compute accuracy and favorite subject (placeholder)
    const accuracy = Math.round(
      (stats.totalAchievements / (stats.totalMaterials || 1)) * 100
    );
    const favorite = stats.favoriteSubject || 'N/A';
    const lines = [
      { label: 'Horas Totais', value: `${stats.totalStudyTime}` },
      { label: 'Exercícios resolvidos', value: `${stats.totalMaterials}` },
      { label: 'Porcentagem de Acertos', value: `${accuracy}%` },
      { label: 'Matéria Favorita', value: favorite },
      { label: 'Sessões de Estudo', value: `${stats.studySessionsCount}` }
    ];
    const startX = 50;
    let startY = canvas.height / 2 - (lines.length * 20);
    lines.forEach((item, idx) => {
      ctx.fillText(
        `${item.label}: ${item.value}`,
        startX,
        startY + idx * 40
      );
    });

    // Return PNG buffer
    return canvas.toBuffer('image/png');
  }
}

module.exports = new CanvasService(); 