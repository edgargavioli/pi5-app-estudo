class WrappedTemplateService {
  /**
   * Gera HTML estilizado para o wrapped do usuário
   */
  generateWrappedHTML(user, stats) {
    const accuracy = Math.round((stats.totalAchievements / (stats.totalMaterials || 1)) * 100);
    const favorite = stats.favoriteSubject || 'N/A';
    
    return `
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Wrapped ${new Date().getFullYear()} - ${user.name}</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .wrapped-container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 40px;
            max-width: 600px;
            width: 100%;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            text-align: center;
            backdrop-filter: blur(10px);
        }
        
        .wrapped-header {
            margin-bottom: 30px;
        }
        
        .wrapped-title {
            font-size: 2.5rem;
            font-weight: bold;
            background: linear-gradient(45deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 10px;
        }
        
        .wrapped-subtitle {
            font-size: 1.2rem;
            color: #666;
            margin-bottom: 20px;
        }
        
        .user-info {
            background: linear-gradient(45deg, #f093fb 0%, #f5576c 100%);
            color: white;
            padding: 20px;
            border-radius: 15px;
            margin-bottom: 30px;
        }
        
        .user-name {
            font-size: 1.8rem;
            font-weight: bold;
            margin-bottom: 10px;
        }
        
        .user-points {
            font-size: 1.2rem;
            opacity: 0.9;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
            border-left: 5px solid;
            transition: transform 0.3s ease;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
        }
        
        .stat-card.primary { border-color: #667eea; }
        .stat-card.secondary { border-color: #f093fb; }
        .stat-card.success { border-color: #4CAF50; }
        .stat-card.warning { border-color: #ff9800; }
        
        .stat-value {
            font-size: 2.5rem;
            font-weight: bold;
            color: #333;
            margin-bottom: 10px;
        }
        
        .stat-label {
            font-size: 1rem;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .motivation-quote {
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            padding: 25px;
            border-radius: 15px;
            font-size: 1.3rem;
            font-style: italic;
            margin-bottom: 20px;
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
        }
        
        .year-badge {
            background: linear-gradient(45deg, #ff9a9e 0%, #fecfef 100%);
            color: #333;
            padding: 10px 20px;
            border-radius: 25px;
            font-weight: bold;
            font-size: 1.1rem;
            display: inline-block;
            margin-top: 20px;
        }
        
        .achievements-section {
            margin-top: 30px;
            padding: 20px;
            background: linear-gradient(45deg, #a8edea 0%, #fed6e3 100%);
            border-radius: 15px;
        }
        
        .achievements-title {
            font-size: 1.5rem;
            font-weight: bold;
            color: #333;
            margin-bottom: 15px;
        }
        
        .achievement-badge {
            display: inline-block;
            background: rgba(255, 255, 255, 0.8);
            padding: 8px 16px;
            border-radius: 20px;
            margin: 5px;
            font-size: 0.9rem;
            color: #333;
        }
        
        @media (max-width: 768px) {
            .wrapped-container {
                padding: 20px;
                margin: 10px;
            }
            
            .wrapped-title {
                font-size: 2rem;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
            }
            
            .stat-value {
                font-size: 2rem;
            }
        }
    </style>
</head>
<body>
    <div class="wrapped-container">
        <div class="wrapped-header">
            <h1 class="wrapped-title">Wrapped ${new Date().getFullYear()}</h1>
            <p class="wrapped-subtitle">Seu ano de estudos em números</p>
        </div>
        
        <div class="user-info">
            <div class="user-name">${user.name}</div>
            <div class="user-points">${user.points} pontos conquistados</div>
        </div>
        
        <div class="stats-grid">
            <div class="stat-card primary">
                <div class="stat-value">${stats.totalStudyTime}h</div>
                <div class="stat-label">Horas de Estudo</div>
            </div>
            
            <div class="stat-card secondary">
                <div class="stat-value">${stats.totalMaterials}</div>
                <div class="stat-label">Exercícios Resolvidos</div>
            </div>
            
            <div class="stat-card success">
                <div class="stat-value">${accuracy}%</div>
                <div class="stat-label">Taxa de Acerto</div>
            </div>
            
            <div class="stat-card warning">
                <div class="stat-value">${stats.studySessionsCount}</div>
                <div class="stat-label">Sessões de Estudo</div>
            </div>
        </div>
        
        <div class="motivation-quote">
            "A dedicação no aprendizado define o seu resultado."
        </div>
        
        <div class="achievements-section">
            <div class="achievements-title">🏆 Suas Conquistas</div>
            <div class="achievement-badge">📚 ${stats.totalAchievements} conquistas desbloqueadas</div>
            <div class="achievement-badge">⭐ Matéria favorita: ${favorite}</div>
            <div class="achievement-badge">🎯 Membro desde ${new Date(user.createdAt).getFullYear()}</div>
        </div>
        
        <div class="year-badge">
            Wrapped ${new Date().getFullYear()} 🎉
        </div>
    </div>
</body>
</html>`;
  }

  /**
   * Gera dados estruturados para o wrapped
   */
  generateWrappedData(user, stats) {
    const accuracy = Math.round((stats.totalAchievements / (stats.totalMaterials || 1)) * 100);
    
    return {
      type: 'wrapped-summary',
      year: new Date().getFullYear(),
      user: {
        name: user.name,
        points: user.points,
        memberSince: new Date(user.createdAt).getFullYear()
      },
      statistics: {
        totalStudyTime: stats.totalStudyTime,
        totalMaterials: stats.totalMaterials,
        accuracy: accuracy,
        favoriteSubject: stats.favoriteSubject || 'N/A',
        studySessionsCount: stats.studySessionsCount,
        totalAchievements: stats.totalAchievements
      },
      highlights: [
        `Você estudou ${stats.totalStudyTime} horas em ${new Date().getFullYear()}`,
        `Resolveu ${stats.totalMaterials} exercícios com ${accuracy}% de acerto`,
        `Completou ${stats.studySessionsCount} sessões de estudo`,
        `Desbloqueou ${stats.totalAchievements} conquistas`
      ],
      message: 'A dedicação no aprendizado define o seu resultado.',
      shareUrl: `${process.env.APP_URL || 'http://localhost:3000'}/wrapped/${user.id}/${new Date().getFullYear()}`
    };
  }
}

module.exports = new WrappedTemplateService(); 