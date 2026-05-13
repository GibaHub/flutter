enum UserRole { aluno, responsavel, admin, professor }

UserRole userRoleFromApi(String value) {
  return switch (value.toUpperCase()) {
    'ALUNO' => UserRole.aluno,
    'RESPONSAVEL' => UserRole.responsavel,
    'ADMIN' => UserRole.admin,
    'PROFESSOR' => UserRole.professor,
    _ => UserRole.aluno,
  };
}

String userRoleToApi(UserRole role) {
  return switch (role) {
    UserRole.aluno => 'ALUNO',
    UserRole.responsavel => 'RESPONSAVEL',
    UserRole.admin => 'ADMIN',
    UserRole.professor => 'PROFESSOR',
  };
}
