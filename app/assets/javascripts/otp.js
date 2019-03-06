$("#user_totp_activated").change(function () {
    if (this.checked) {
        $('#otp_modal').modal();
    }
});

$('#otp_modal').on('hide.bs.modal', function () {
    $("#user_totp_activated").prop("checked", false);
});

$('#verify_top_btn').on('click', function () {
    const otp = document.getElementById("otp").value;
    console.log("Verified");
    console.log(otp);
    $('#otp_modal').modal('hide');
    $("#user_totp_activated").prop("checked", true); // todo: replace with ajax call to verify otp by user model
});