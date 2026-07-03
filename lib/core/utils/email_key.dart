String emailToDocId(String email) {
  return email.toLowerCase().trim().replaceAll('@', '_at_').replaceAll('.', '_');
}
