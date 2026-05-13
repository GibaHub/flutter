enum AppModule {
  clientes,
  titulos,
  limites,
  inadimplencia,
  vendas,
  usuarios,
  baixas,
  relatorios,
  indenizacoes,
  despesas,
  vendedores,
  compras,
  estoque,
  pagamentos,
  inventario,
  aprovacoes,
  pdv,
  descontos,
}

extension AppModuleX on AppModule {
  String get key => name;

  String get apiKey {
    switch (this) {
      case AppModule.clientes:
        return 'cadcli';
      case AppModule.titulos:
        return 'vertit';
      case AppModule.limites:
        return 'altlim';
      case AppModule.inadimplencia:
        return 'inadimplente';
      case AppModule.vendas:
        return 'rvenda';
      case AppModule.usuarios:
        return 'usuarios';
      case AppModule.baixas:
        return 'cancbaixa';
      case AppModule.relatorios:
        return 'relcom';
      case AppModule.indenizacoes:
        return 'indeni';
      case AppModule.despesas:
        return 'despesas';
      case AppModule.vendedores:
        return 'rkvenda';
      case AppModule.compras:
        return 'relcom';
      case AppModule.estoque:
        return 'conest';
      case AppModule.pagamentos:
        return 'pagfor';
      case AppModule.inventario:
        return 'invent';
      case AppModule.aprovacoes:
        return 'aprov';
      case AppModule.pdv:
        return 'pdvlj';
      case AppModule.descontos:
        return 'descon';
    }
  }

  String get label {
    switch (this) {
      case AppModule.clientes:
        return 'Clientes';
      case AppModule.titulos:
        return 'Títulos';
      case AppModule.limites:
        return 'Limites';
      case AppModule.inadimplencia:
        return 'Inadimplência';
      case AppModule.vendas:
        return 'Resumo Venda';
      case AppModule.usuarios:
        return 'Usuários App';
      case AppModule.baixas:
        return 'Baixas';
      case AppModule.relatorios:
        return 'Relatórios';
      case AppModule.indenizacoes:
        return 'Indenizações';
      case AppModule.despesas:
        return 'Despesas';
      case AppModule.vendedores:
        return 'Ranking Vendedores';
      case AppModule.compras:
        return 'Compras';
      case AppModule.estoque:
        return 'Estoque';
      case AppModule.pagamentos:
        return 'Pagamentos';
      case AppModule.inventario:
        return 'Inventário';
      case AppModule.aprovacoes:
        return 'Aprovações';
      case AppModule.pdv:
        return 'PDV';
      case AppModule.descontos:
        return 'Descontos';
    }
  }
}

