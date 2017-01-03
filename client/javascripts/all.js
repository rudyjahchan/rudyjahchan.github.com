function toggleMenuActive(element) {
	element.classList.toggle('menu-active');
}

function onMenuClick(event) {
	event.preventDefault();
	const activableElements = document.getElementsByClassName('menu-activable');
	Array.prototype.forEach.call(activableElements, toggleMenuActive);
	return false;
}

document.addEventListener("DOMContentLoaded", function(event) {
	const toggle = document.getElementById('menu-toggle');
	toggle.addEventListener('click', onMenuClick);
});
