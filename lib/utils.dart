createUnionIdGener() {
  int id = 0;
  return () {
    id++;
    return id;
  };
}
