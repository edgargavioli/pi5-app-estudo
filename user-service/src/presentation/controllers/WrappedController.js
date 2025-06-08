const wrappedTemplateService = require('../../infrastructure/services/WrappedTemplateService');

class WrappedController {
  
  /**
   * Gerar dados mockados para demonstração
   */
  _generateMockData(userId) {
    return {
      user: {
        id: userId,
        name: 'Usuário Demo',
        email: 'usuario@demo.com',
        points: 1250,
        createdAt: new Date('2024-01-15').toISOString()
      },
      stats: {
        totalStudyTime: 45,
        totalMaterials: 128,
        totalAchievements: 15,
        favoriteSubject: 'Matemática',
        studySessionsCount: 32
      },
      achievements: [
        { id: 1, name: 'Primeiro Login', description: 'Fez seu primeiro acesso' },
        { id: 2, name: 'Estudioso', description: 'Completou 10 sessões de estudo' },
        { id: 3, name: 'Persistente', description: 'Estudou por 7 dias consecutivos' }
      ],
      pointsTransactions: [
        { date: '2024-12-01', points: 50, reason: 'Sessão de estudo concluída' },
        { date: '2024-12-02', points: 25, reason: 'Quiz completado' },
        { date: '2024-12-03', points: 100, reason: 'Prova finalizada' }
      ]
    };
  }

  /**
   * Get wrapped user data (aggregated view)
   */
  async getUserWrapped(req, res) {
    try {
      console.log('🎯 getUserWrapped iniciado');
      const userId = req.params.id;
      console.log('📋 userId:', userId);
      
      const mockData = this._generateMockData(userId);
      console.log('📊 mockData gerado:', Object.keys(mockData));
      
      // Usar o novo serviço para dados estruturados
      const wrappedData = wrappedTemplateService.generateWrappedData(mockData.user, mockData.stats);
      console.log('✅ wrappedData gerado:', Object.keys(wrappedData));
      
      res.json(wrappedData);
    } catch (error) {
      console.error('❌ Erro em getUserWrapped:', error);
      res.status(500).json({ error: 'Internal server error', details: error.message });
    }
  }

  /**
   * Get user achievements
   */
  async getUserAchievements(req, res) {
    try {
      const userId = req.params.id;
      const mockData = this._generateMockData(userId);
      res.json(mockData.achievements);
    } catch (error) {
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  /**
   * Get user points history
   */
  async getUserPointsHistory(req, res) {
    try {
      const userId = req.params.id;
      const mockData = this._generateMockData(userId);
      res.json(mockData.pointsTransactions);
    } catch (error) {
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  /**
   * Generate wrapped summary (JSON format)
   */
  async getWrappedImage(req, res) {
    try {
      const userId = req.params.id;
      const mockData = this._generateMockData(userId);
      
      // Retornar dados JSON em vez de imagem
      const wrappedData = wrappedTemplateService.generateWrappedData(mockData.user, mockData.stats);
      
      res.json({
        ...wrappedData,
        htmlUrl: `${req.protocol}://${req.get('host')}/api/wrapped/${userId}/html`,
        note: 'Para visualização HTML, acesse a URL htmlUrl'
      });
    } catch (error) {
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  // 🎨 NOVO: Endpoint para HTML estilizado
  async getWrappedHTML(req, res) {
    try {
      const userId = req.params.id;
      const mockData = this._generateMockData(userId);
      
      // Gerar HTML estilizado
      const htmlContent = wrappedTemplateService.generateWrappedHTML(mockData.user, mockData.stats);
      
      res.setHeader('Content-Type', 'text/html');
      res.send(htmlContent);
    } catch (error) {
      res.status(500).send(`
        <html>
          <body style="font-family: Arial; text-align: center; padding: 50px;">
            <h1>🚨 Erro interno</h1>
            <p>Ocorreu um erro ao gerar o wrapped.</p>
          </body>
        </html>
      `);
    }
  }
}

module.exports = new WrappedController(); 