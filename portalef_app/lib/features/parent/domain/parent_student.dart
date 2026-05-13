class ParentStudent {
  const ParentStudent({
    required this.id,
    required this.nome,
    required this.email,
  });

  final int id;
  final String nome;
  final String email;

  factory ParentStudent.fromJson(Map<String, Object?> json) {
    return ParentStudent(
      id: (json['id'] as num).toInt(),
      nome: (json['nome'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
    );
  }
}

