function mostrarNota(noteId) {
    document.getElementById("padreContenido").setAttribute("class","col-9");

    var cont = document.getElementById("contenido")

    fetch("/notes/"+noteId)
    .then(response => response.json())
    .then(data => {
        cont.innerHTML = "";

        console.log(data)
        
        var edit = document.createElement("a");
        edit.setAttribute("href","/notes/"+noteId+"/edit");
        edit.setAttribute("class","btn btn-primary");
        edit.innerHTML = "Editar";
        cont.appendChild(edit);

        var del = document.createElement("button");
        del.setAttribute("class","btn btn-secondary");
        del.setAttribute("onclick","eliminarNota("+noteId+")");
        del.innerHTML = "Eliminar";
        cont.appendChild(del);

        var p = document.createElement("p");
        p.innerHTML = data.text;
        cont.appendChild(p);
    
        var p1 = document.createElement("p");
        p1.innerHTML = data.list;
        cont.appendChild(p1);
    
        data.image.forEach(element => {
            var img = document.createElement("img");
            img.src = element;
            img.style.width = "120";
            img.style.height = "120";
            cont.appendChild(img);
        });
    })
    .catch(error => {
        console.log('Error:', error);
    });
}

function eliminarNota(noteId) {
    if (confirm('¿Estás seguro?')) {
        fetch(`/notes/${noteId}`, {
            method: 'DELETE',
            headers: {
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
            }
        }).then(response => {
            window.location.href = "/notes";
        }).catch(error => console.error('Error:', error));
    }
}