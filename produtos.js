function toggleSubGrupo(origin) {
  let parent = origin.parentElement;
  let list = parent.getElementsByTagName('ul')[0];
  list.classList.toggle("display-none");
}