export class HateoasConfig {
    static generateLinks(baseUrl, resource, item) {
        const id = typeof item === 'string' ? item : item.id;
        
        const links = {
            self: {
                href: `${baseUrl}/${resource}/${id}`,
                method: 'GET',
                type: 'application/json'
            },
            update: {
                href: `${baseUrl}/${resource}/${id}`,
                method: 'PUT',
                type: 'application/json'
            },
            delete: {
                href: `${baseUrl}/${resource}/${id}`,
                method: 'DELETE'
            }
        };

        // Links específicos para cada recurso baseados em relacionamentos
        switch (resource) {
            case 'materias':
                links.provas = {
                    href: `${baseUrl}/provas?materiaId=${id}`,
                    method: 'GET',
                    type: 'application/json',
                    title: 'Provas desta matéria'
                };
                links.sessoes = {
                    href: `${baseUrl}/sessoes?materiaId=${id}`,
                    method: 'GET',
                    type: 'application/json',
                    title: 'Sessões de estudo desta matéria'
                };
                links.create_prova = {
                    href: `${baseUrl}/provas`,
                    method: 'POST',
                    type: 'application/json',
                    title: 'Criar prova para esta matéria'
                };
                break;
                
            case 'provas':
                const materiaId = typeof item === 'object' ? item.materiaId : null;
                if (materiaId) {
                    links.materia = {
                        href: `${baseUrl}/materias/${materiaId}`,
                        method: 'GET',
                        type: 'application/json',
                        title: 'Matéria desta prova'
                    };
                }
                links.sessoes = {
                    href: `${baseUrl}/sessoes?provaId=${id}`,
                    method: 'GET',
                    type: 'application/json',
                    title: 'Sessões de estudo para esta prova'
                };
                links.create_sessao = {
                    href: `${baseUrl}/sessoes`,
                    method: 'POST',
                    type: 'application/json',
                    title: 'Criar sessão de estudo para esta prova'
                };
                break;
                
            case 'sessoes':
                const sessaoMateriaId = typeof item === 'object' ? item.materiaId : null;
                const sessaoProvaId = typeof item === 'object' ? item.provaId : null;
                
                if (sessaoMateriaId) {
                    links.materia = {
                        href: `${baseUrl}/materias/${sessaoMateriaId}`,
                        method: 'GET',
                        type: 'application/json',
                        title: 'Matéria desta sessão'
                    };
                }
                
                if (sessaoProvaId) {
                    links.prova = {
                        href: `${baseUrl}/provas/${sessaoProvaId}`,
                        method: 'GET',
                        type: 'application/json',
                        title: 'Prova desta sessão'
                    };
                }
                
                // Só mostra link de finalizar se não estiver finalizada
                const isFinished = typeof item === 'object' && item.tempoFim;
                if (!isFinished) {
                    links.finalizar = {
                        href: `${baseUrl}/sessoes/${id}/finalizar`,
                        method: 'POST',
                        type: 'application/json',
                        title: 'Finalizar esta sessão'
                    };
                }
                break;
        }

        return links;
    }

    static wrapResponse(data, baseUrl, resource, item = null) {
        const itemForLinks = item || data;
        return {
            data,
            _links: this.generateLinks(baseUrl, resource, itemForLinks),
            _meta: {
                resource: resource,
                timestamp: new Date().toISOString(),
                version: "1.0"
            }
        };
    }

    static wrapCollectionResponse(data, baseUrl, resource, pagination = null) {
        const response = {
            data: data.map(item => ({
                ...item,
                _links: this.generateLinks(baseUrl, resource, item)
            })),
            _links: {
                self: {
                    href: `${baseUrl}/${resource}`,
                    method: 'GET',
                    type: 'application/json'
                },
                create: {
                    href: `${baseUrl}/${resource}`,
                    method: 'POST',
                    type: 'application/json',
                    title: `Criar novo ${resource.slice(0, -1)}`
                }
            },
            _meta: {
                resource: resource,
                count: data.length,
                timestamp: new Date().toISOString(),
                version: "1.0"
            }
        };

        // Adicionar links de paginação se fornecidos
        if (pagination) {
            const { page, limit, total, totalPages } = pagination;
            
            response._meta.pagination = {
                page,
                limit,
                total,
                totalPages
            };

            if (page > 1) {
                response._links.prev = {
                    href: `${baseUrl}/${resource}?page=${page - 1}&limit=${limit}`,
                    method: 'GET',
                    type: 'application/json'
                };
            }

            if (page < totalPages) {
                response._links.next = {
                    href: `${baseUrl}/${resource}?page=${page + 1}&limit=${limit}`,
                    method: 'GET',
                    type: 'application/json'
                };
            }

            response._links.first = {
                href: `${baseUrl}/${resource}?page=1&limit=${limit}`,
                method: 'GET',
                type: 'application/json'
            };

            response._links.last = {
                href: `${baseUrl}/${resource}?page=${totalPages}&limit=${limit}`,
                method: 'GET',
                type: 'application/json'
            };
        }

        return response;
    }

    // Método para criar links de erro (nível 3 de maturidade)
    static wrapErrorResponse(error, statusCode, baseUrl) {
        return {
            error: {
                message: error,
                code: statusCode,
                timestamp: new Date().toISOString()
            },
            _links: {
                home: {
                    href: baseUrl,
                    method: 'GET',
                    type: 'application/json',
                    title: 'Voltar ao início'
                },
                docs: {
                    href: `${baseUrl}/swagger`,
                    method: 'GET',
                    type: 'text/html',
                    title: 'Documentação da API'
                }
            }
        };
    }
} 