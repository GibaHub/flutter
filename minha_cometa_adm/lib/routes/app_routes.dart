import 'package:flutter/material.dart';
import 'package:minha_cometa_adm/screens/vendas_filiais_page.dart';
import '../screens/descontos/selecao_desconto_page.dart';
import '../screens/descontos/desconto_baixa_page.dart';
import '../screens/descontos/desconto_venda_page.dart';
import '../screens/descontos/alterar_entrada_page.dart';
import '../pages/admin_users_page.dart';
import '/screens/cadastro_cliente_page.dart';
import '/screens/home_page.dart';
import '/screens/limites_page.dart';
import '/screens/under_construction_page.dart';
import '/widgets/permission_guard.dart';
import '/widgets/protected_route.dart';

final routes = {
  '/home': (context) => const ProtectedRoute(child: HomePage()),
  '/clientes': (context) => const ProtectedRoute(
        child:
            PermissionGuard(module: 'clientes', child: CadastroClientePage()),
      ),
  '/limites': (context) => const ProtectedRoute(
        child: PermissionGuard(module: 'limites', child: LimitesPage()),
      ),
  '/vendedores': (context) => const ProtectedRoute(
        child:
            PermissionGuard(module: 'vendedores', child: VendasFiliaisPage()),
      ),
  '/alterarLimite': (context) => const ProtectedRoute(child: LimitesPage()),
  '/detalhes-cliente': (context) => const ProtectedRoute(
      child: Placeholder()), // Detalhes é acessado com parâmetro
  '/descontos': (context) => const ProtectedRoute(
        child: PermissionGuard(module: 'baixas', child: SelecaoDescontoPage()),
      ),
  '/descontos/baixa': (context) => const ProtectedRoute(
        child: PermissionGuard(module: 'baixas', child: DescontoBaixaPage()),
      ),
  '/descontos/venda': (context) => const ProtectedRoute(
        child: PermissionGuard(module: 'baixas', child: DescontoVendaPage()),
      ),
  '/descontos/alterar-entrada': (context) => const ProtectedRoute(
        child: PermissionGuard(module: 'baixas', child: AlterarEntradaPage()),
      ),
  '/usuarios-app': (context) => const ProtectedRoute(
        child: PermissionGuard(
          module: 'usuarios',
          requireAdmin: true,
          child: AdminUsersPage(),
        ),
      ),
  '/compras': (context) => const ProtectedRoute(
        child: PermissionGuard(
          module: 'compras',
          child: UnderConstructionPage(pageTitle: 'Compras'),
        ),
      ),
};
