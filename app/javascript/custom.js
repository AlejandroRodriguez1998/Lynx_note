function checkInput(currentInput) {
    const lastInput = document.querySelector('#listInputsContainer').lastElementChild;
    if (currentInput === lastInput && currentInput.value.trim() !== "") {
      const newInput = document.createElement("input");
      newInput.setAttribute("type", "text");
      newInput.setAttribute("name", "note[content][][value][]");
      newInput.classList.add("form-control", "list-input", "mb-1");
      newInput.setAttribute("oninput", "checkInput(this)");
      newInput.placeholder = "Add another item";
  
      document.querySelector('#listInputsContainer').appendChild(newInput);
    }
}

function showNote(noteId) {
    // Añadir la clase 'selected' al elemento clickeado y quitarla de los demás
    document.querySelectorAll('.listSelected').forEach(function(item) {
        item.classList.remove('selected'); 
        //Con esto comprobamos si el id del elemento clickeado es igual al id de la nota
        if (item.getAttribute('onclick').includes(noteId.toString())) {
            item.classList.add('selected'); 
        }
    });

    document.getElementById("fatherContent").setAttribute("class","col-12 col-md-9 mt-2 mt-md-0");
    var cont = document.getElementById("content")

    fetch("/notes/"+noteId, {
        headers: {
          'Accept': 'application/json'
        }
      })
    .then(response => response.json())
    .then(data => {
        cont.innerHTML = "";

        var edit = document.createElement("a");
        edit.setAttribute("href","/notes/"+noteId+"/edit");
        edit.setAttribute("class","btn color_button_green fw-semibold mb-3");
        edit.innerHTML = "Edit";
        cont.appendChild(edit);

        var del = document.createElement("button");
        del.setAttribute("class","btn color_button_brown fw-semibold mb-3 ms-2");
        del.setAttribute("onclick","deleteNote("+noteId+")");
        del.innerHTML = "Delete";
        cont.appendChild(del);

        data.content.forEach(element => {
            element = JSON.parse(element);

            if (element.type == "text") {
                var p = document.createElement("p");
                p.innerHTML = element.value;
                cont.appendChild(p);
            } else if (element.type == "list") {
                var ul = document.createElement("ul");
                var dataUl = element.value.split(";")

                dataUl.forEach(element => {
                    var li = document.createElement("li");
                    li.innerHTML = element;
                    ul.appendChild(li);
                });

                cont.appendChild(ul);
            } else if (element.type == "file") {
                var cardGroup = document.createElement("div");
                cardGroup.setAttribute("class","card-group");
                var card = document.createElement("div");
                card.setAttribute("class","card color_card");
    
                var cardBody = document.createElement("div");
                cardBody.setAttribute("class","card-body text-center");
    
                var img = document.createElement("img");
                img.src = element.value;
                img.style.width = "150px";
                img.style.height = "150px";
    
                cardBody.appendChild(img);
                card.appendChild(cardBody);
                cardGroup.appendChild(card);
                cont.appendChild(cardGroup);
            }
        }); 
    })
    .catch(error => {
        console.log('Error:', error);
    });
}

function deleteNote(noteId) {
    if (confirm('Are you sure?')) {
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
