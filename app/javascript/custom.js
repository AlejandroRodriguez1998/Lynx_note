
function addContentType(contentType) {
    var container = document.getElementById('contentContainer');
    var contentDiv = document.createElement('div');
    contentDiv.setAttribute('class', 'field mb-2');
    
    var typeInput = document.createElement('input');
    typeInput.setAttribute('type', 'hidden');
    typeInput.setAttribute('name', `note[content][][type]`);
    typeInput.value = contentType;

    contentDiv.appendChild(typeInput);

    var label = document.createElement('label');
    label.setAttribute('class', 'form-label');
    
    contentDiv.appendChild(label);

    if (contentType === 'list'){
        label.innerHTML = 'List';

        var div = document.createElement('div');
        div.setAttribute('id', 'listInputsContainer');

        contentDiv.appendChild(div);

        var input = document.createElement('input');
        input.setAttribute('name', `note[content][][value][]`);
        input.setAttribute('class', 'form-control list-input mb-1');
        input.setAttribute('placeholder', 'Add an item to the list');
        input.setAttribute('oninput', 'checkInput(this)');
        input.setAttribute('type', 'text');

        div.appendChild(input);

    }else if (contentType === 'text'){
        label.innerHTML = 'Text';

        var valueInput = document.createElement('textarea');
        valueInput.setAttribute('name', `note[content][][value]`);
        valueInput.setAttribute('class', 'form-control');
        valueInput.setAttribute('rows', '3');
        valueInput.setAttribute('placeholder', 'Any text you want to add to the note');
        
        contentDiv.appendChild(valueInput);
    }else{
        label.innerHTML = 'Image';

        var valueInput = document.createElement('input');
        valueInput.setAttribute('name', `note[content][][value]`);
        valueInput.setAttribute('class', 'form-control');
        valueInput.setAttribute('type', 'file');
        
        contentDiv.appendChild(valueInput);
    }

    container.appendChild(contentDiv);
}

function checkInput(currentInput) {
    const lastInput = currentInput.parentNode.lastElementChild;
    if (currentInput === lastInput && currentInput.value.trim() !== "") {
      const newInput = document.createElement("input");
      newInput.setAttribute("type", "text");
      newInput.setAttribute("name", "note[content][][value][]");
      newInput.classList.add("form-control", "list-input", "mb-1");
      newInput.setAttribute("oninput", "checkInput(this)");
      newInput.placeholder = "Add another item";
  
      currentInput.parentNode.appendChild(newInput);
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

        var id = document.createElement("p");
        id.setAttribute("id","id_note");
        id.setAttribute("class","d-none");
        id.innerHTML = "index;" + noteId;
        cont.appendChild(id);

        var edit = document.createElement("a");
        edit.setAttribute("href","/notes/"+noteId+"/edit");
        edit.setAttribute("class","btn color_button_green fw-semibold mb-3");
        edit.innerHTML = "Edit";
        cont.appendChild(edit);

        var del = document.createElement("button");
        del.setAttribute("class","btn color_button_brown fw-semibold mb-3 ms-2");
        del.setAttribute("onclick","createToastConfirm('note',false,'"+noteId+"')");
        del.innerHTML = "Delete";
        cont.appendChild(del);

        const sharing = document.createElement('button');
        sharing.setAttribute('class', 'btn color_button_green fw-semibold mb-3 ms-2');
        sharing.setAttribute('data-bs-toggle', 'modal');
        sharing.setAttribute('data-bs-target', '#modalShare');
        sharing.innerHTML = 'Share';
        cont.appendChild(sharing);

        if (data.shared) {
            refillSharing(data.shared_id.$oid, 'edit');
        }else {
            refillSharing(noteId, 'new');
        }

        if (data.note.content !== null) {
            data.note.content.forEach(element => {
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
                    cardGroup.setAttribute("class","card-group mb-3");
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
        }
    })
    .catch(error => console.error('Error:', error));
}

function refillSharing(objectId, typeMethod) {
    var sharing = document.getElementById('contentSharing');
    sharing.innerHTML = "";

    url = typeMethod == "new" ? `/sharing/object=${objectId}` : `/sharing_edit/${objectId}`;

    fetch(url,{
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest'
        }
    }).then(response => response.text())
    .then(html => {
        sharing.innerHTML = html;
    }).catch(error => console.error('Error loading the form:', error));
}

function shareContent(objectId, typeMethod) {
    refillSharing(objectId, typeMethod);
    document.getElementById('buttonModalShare').click();
}

function shareDelete(sharingId) {
    document.getElementById("modalClose").click();
    createToastConfirm('sharing', false, sharingId);
}

function deleteNote(admin,noteId) {
    url = admin ? `/admin/notes/${noteId}` : `/notes/${noteId}`;

    fetch(url, {
        method: 'DELETE',
        headers: {
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        }
    }).then(response => {
        if(admin){
            window.location.href = "/admin/notes";
        }else{
            window.location.href = "/notes";
        }
    }).catch(error => console.error('Error:', error));
    
}

function deleteCollection(admin,collectionId) {
    url = admin ? `/admin/collections/${collectionId}` : `/collections/${collectionId}`;

    fetch(url, {
        method: 'DELETE',
        headers: {
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        }
    }).then(response => {
        if (admin) {
            window.location.href = "/admin/collections";
        } else {
            window.location.href = "/collections";
        }
    }).catch(error => console.error('Error:', error));
    
}

function deleteUser(admin,userId) {
    url = admin ? `/admin/users/${userId}` : `/users/${userId}`;

    fetch(url, {
        method: 'DELETE',
        headers: {
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        }
    }).then(response => {
        if(admin){
            window.location.href = "/admin/users";
        }else{
            window.location.href = "/home?notice=user";         
        }
    }).catch(error => console.error('Error:', error));
    
}

function deleteNotification(notificationId) {
    fetch(`/deleteNotification/${notificationId}`, {
        method: 'DELETE',
        headers: {
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        }
    })
    .then(response => {
        console.log('Notification deleted');
        putNotification();
    })
    .catch(error => console.error('Error:', error));
}

function deleteFriendship(admin,friendShipId) {
    url = admin ? `/admin/friendships/${friendShipId}` : `/friendships/${friendShipId}`;

    fetch(url, {
        method: 'DELETE',
        headers: {
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        }
    }).then(response => {
        if(admin){
            window.location.href = "/admin/friendships";
        }else{
            window.location.href = "/friendships";         
        }
    }).catch(error => console.error('Error:', error));
}

function deleteSharing(admin, sharingId) {
    page = document.getElementById('namePage').innerHTML;

    fetch(`/sharing_delete/${sharingId}`, {
        method: 'DELETE',
        headers: {
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        }
    })
    .then(response => {
        if (page == 'Notes') {
            note = document.getElementById('id_note').innerHTML.split(';');

            if (note[0] === "index") {
                window.location.href = "/notes?number="+note[1];
            } else if (note[0] === "show") {
                window.location.href = "/notes/" + note[1];
            }

        } else {
            window.location.href = "/collections";
        }
    })
}

function acceptFriendship(admin, friendshipId) {
    fetch(`/friendships/${friendshipId}`, {
        method: 'PUT',
        headers: {
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        }
    })
    .then(response => {
        window.location.href = "/friendships";
    })
    .catch(error => console.error('Error:', error));
}

function createToast(message) {
    const toast = document.createElement('div');
    toast.className = 'toast align-items-center border-0';
    toast.setAttribute('role', 'alert');
    toast.setAttribute('aria-live', 'assertive');
    toast.setAttribute('aria-atomic', 'true');

    const flexContainer = document.createElement('div');
    flexContainer.className = 'd-flex';

    const toastBody = document.createElement('div');
    toastBody.className = 'toast-body';
    toastBody.textContent = message;

    const closeButton = document.createElement('button');
    closeButton.type = 'button';
    closeButton.className = 'btn-close me-2 m-auto';
    closeButton.setAttribute('data-bs-dismiss', 'toast');
    closeButton.setAttribute('aria-label', 'Close');
    closeButton.onclick = function() { toast.remove(); }; 

    flexContainer.appendChild(toastBody);
    flexContainer.appendChild(closeButton);
    toast.appendChild(flexContainer);

    document.getElementById('toast-container').appendChild(toast);
    new bootstrap.Toast(toast).show();
}

function createToastConfirm(type,admin, typeId) {
    const toast = document.createElement('div');
    toast.className = 'toast align-items-center border-0';
    toast.setAttribute('role', 'alert');
    toast.setAttribute('aria-live', 'assertive');
    toast.setAttribute('aria-atomic', 'true');
    toast.setAttribute('data-bs-autohide', 'false');

    const toastBody = document.createElement('div');
    toastBody.className = 'toast-body text-center';
    toastBody.textContent = 'Are you sure?';

    const buttonGroup = document.createElement('div');
    buttonGroup.className = 'mt-2 pt-2 border-top';

    const actionMap = {
        note: deleteNote,
        collection: deleteCollection,
        user: deleteUser,
        friendship: deleteFriendship,
        acceptFriendship: acceptFriendship,
        sharing: deleteSharing
    };

    const actionButton = document.createElement('button');
    actionButton.type = 'button';
    actionButton.className = 'btn color_button_green btn-sm me-1';
    actionButton.textContent = 'Accept';
    actionButton.onclick = function() { 
        const action = actionMap[type];
        if (action) {
            action(admin, typeId);
        } else {
            console.error('Action not defined for type:', type);
        }
    }

    const closeButton = document.createElement('button');
    closeButton.type = 'button';
    closeButton.className = 'btn color_button_brown btn-sm';
    closeButton.setAttribute('data-bs-dismiss', 'toast');
    closeButton.textContent = 'Cancel';
    closeButton.onclick = function() { toast.remove(); };

    buttonGroup.appendChild(actionButton);
    buttonGroup.appendChild(closeButton);
    toastBody.appendChild(buttonGroup);
    toast.appendChild(toastBody);

    document.getElementById('toast-delete').appendChild(toast);
    new bootstrap.Toast(toast).show();
}

function putNotification() {
    number = document.getElementById('numberNotification');
    content = document.getElementById('contentNotification');
    
    fetch('/getNotifications', {
        method: 'GET',
        headers: {
            'Accept': 'application/json'
        }
    })
    .then(response => response.json())
    .then(data => {
        number.innerHTML = "";
        content.innerHTML = "";

        number.innerHTML = data.length;

        if (data.length == 0) {
            var p_not = document.createElement("p");
            p_not.className = 'text-center my-2';
            p_not.innerHTML = 'No Notifications';
            content.appendChild(p_not);
        }

        data.forEach(element => {
            var divFlex = document.createElement('div');
            divFlex.className = 'd-flex bd-highlight mt-2 ms-1';

            var p = document.createElement("p");
            p.className = 'me-auto mb-2 bd-highlight';
            p.innerHTML = element.message;

            var i = document.createElement("i");
            i.className = 'bi bi-x bd-highlight';
            i.onclick = function() {
                deleteNotification(element._id.$oid);
            }

            divFlex.appendChild(p);
            divFlex.appendChild(i);
            content.appendChild(divFlex);
        });
        
    })
    .catch(error => console.error('Error:', error)); 
}

function showNotification(){
    var $notificationBox = $('#contentNotification');

    if ($notificationBox.css('display') === 'none') {
        $notificationBox.show(); 
    } else {
        $notificationBox.hide();
    }
}

function filterSharing(event) {
    var value = $($(event.target)).val().toLowerCase();
    $("#listContent li").filter(function() {
        $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
    });
}


$(document).ready(function(){
    var userStatus = document.querySelector('meta[name="status"]').getAttribute('content');

    if (userStatus === 'true') {
        var urlParams = new URLSearchParams(window.location.search);
        
        
        var alert = urlParams.get('notice');
        var IDNote = urlParams.get('number');
        var timer;

        if (alert) { createToast("Your account has been deleted"); }
        if (IDNote) { showNote(IDNote); }
 
        putNotification();

        $('#contentNotification').mouseenter(function() {
            clearTimeout(timer); 
        }).mouseleave(function() {
            if ($(this).is(':visible')) { timer = setTimeout(showNotification, 2300); }
        }).click(function() {
            if (!$(this).is(':visible')) { 
                clearTimeout(timer); 
            } else {
                timer = setTimeout(showNotification, 2300); 
            }
        });
    }
   
    $("#inputContent").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $("#listContent li").filter(function() {
        $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
        });
    });

    $("#inputFriendship_one").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $("#listFriendship_one li").filter(function() {
        $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
        });
    });

    $("#tableContentTD").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $("#contentTable tr").filter(function() {
            var cellText = $(this).find('#tdSearch').text().toLowerCase();
            $(this).toggle(cellText.indexOf(value) > -1);
        });
    });

    $("#tableContentTDs").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $("#contentTable tr").filter(function() {
            var cellText1 = $(this).find('#tdSearch1').text().toLowerCase();
            var cellText2 = $(this).find('#tdSearch2').text().toLowerCase();
            $(this).toggle(cellText1.indexOf(value) > -1 || cellText2.indexOf(value) > -1);
        });
    });
});   