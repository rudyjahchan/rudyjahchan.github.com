!function(t){function e(o){if(n[o])return n[o].exports;var r=n[o]={exports:{},id:o,loaded:!1};return t[o].call(r.exports,r,r.exports,e),r.loaded=!0,r.exports}var n={};return e.m=t,e.c=n,e.p="",e(0)}([function(t,e,n){n(1),t.exports=n(2)},function(t,e){function n(t){t.classList.toggle("menu-active")}function o(t){t.preventDefault();const e=document.getElementsByClassName("menu-activable");return Array.prototype.forEach.call(e,n),!1}document.addEventListener("DOMContentLoaded",function(t){const e=document.getElementById("menu-toggle");e.addEventListener("click",o)})},function(t,e){}]);