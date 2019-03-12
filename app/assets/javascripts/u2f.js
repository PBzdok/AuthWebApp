$("#user_u2f_activated").change(function () {
    if (this.checked) {
        $('#u2f_modal').modal();
    }
});

$('#u2f_modal').on('hide.bs.modal', function () {
    $("#user_u2f_activated").prop("checked", false);
});