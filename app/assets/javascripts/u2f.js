$("#user_u2f_activated").change(function () {
    if (this.checked) {
        $('#u2f_modal').modal();
    }
});

$('#u2f_modal').on('hide.bs.modal', function () {
    $("#user_u2f_activated").prop("checked", false);
});

$('#sign_button_u2f').on('click', function () {
    $('#u2f_authentication_modal').modal();
});