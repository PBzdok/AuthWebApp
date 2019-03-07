$("#user_totp_activated").change(function () {
    if (this.checked) {
        $('#otp_modal').modal();
    }
});

$('#otp_modal').on('hide.bs.modal', function () {
    $("#user_totp_activated").prop("checked", false);
});

$('#verify_top_btn').on('click', function () {
    const applicationPath = location.pathname;
    let totp = document.getElementById("otp").value;
    let id = applicationPath.split("/")[2];
    $.ajax({
        type: "GET",
        url: `/users/${id}/verify_otp`,
        data: {
            user: {
                totp: totp
            }
        },
        dataType: "json",
        success: function (data) {
            console.log("success");
            console.log(data)
        },
        error: function (data) {
            console.error("Asynchronous request failed!");
            console.log(data)
        }
    });
    $('#otp_modal').modal('hide');
    $("#user_totp_activated").prop("checked", true); // todo: replace with ajax call to verify otp by user model
});