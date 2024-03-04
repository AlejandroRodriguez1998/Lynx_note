function mostrarNota(noteId) {
    document.getElementById("padreContenido").setAttribute("class","col-9");

    var cont = document.getElementById("contenido")

    fetch("/notes/"+noteId)
    .then(response => response.json())
    .then(data => {
        cont.innerHTML = "";

        var p = document.createElement("p");
        p.innerHTML = data.text;
        cont.appendChild(p);
    
        var p1 = document.createElement("p");
        p1.innerHTML = data.list;
        cont.appendChild(p1);
    
        var img2 = document.createElement("img");
        img2.src = data.image;
        img2.style.width = "120";
        img2.style.height = "120";
        cont.appendChild(img2);
    })
    .catch(error => {
        console.log('Error:', error);
    });
}