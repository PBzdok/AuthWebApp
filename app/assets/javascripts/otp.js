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
        url: `/users/${id}/verify_otp.json`,
        data: {
            user: {
                totp: totp
            }
        },
        dataType: "json",
        success: function (data) {
            if (data["totp_valid"]) {
                $('#otp_modal').modal('hide');
                $("#user_totp_activated").prop("checked", true);
                alert("TOTP successfully confirmed!")
            }
            else {
                document.getElementById("otp").style.borderColor = "red";
                alert("TOTP wrong!");
                $("#user_totp_activated").prop("checked", false);
            }
        },
        error: function (data) {
            console.error("Asynchronous request failed!");
            console.log(data)
        }
    });
});