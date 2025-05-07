String getFullImageUrl(String? path) {
  if (path == null || path.isEmpty) {
    return 'https://via.placeholder.com/150'; // fallback if no logo
  }
  if (path.startsWith('http')) {
    return path; // already full url
  }
  return 'http://10.0.2.2:5000$path'; // add backend address
}
