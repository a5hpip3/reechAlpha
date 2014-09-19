$(function() {
    /* For reech_pro purposes */
    var reech_pro = $("<div />").css({
        position: "fixed",
        top: "150px",
        right: "0",
        background: "rgba(0, 0, 0, 0.7)",
        "border-radius": "5px 0px 0px 5px",
        padding: "10px 15px",
        "font-size": "16px",
        "z-index": "999999",
        cursor: "pointer",
        color: "#ddd"
    }).html("<i class='fa fa-gear'></i>").addClass("no-print");

    var reech_pro_settings = $("<div />").css({
        "padding": "10px",
        position: "fixed",
        top: "130px",
        right: "-200px",
        background: "#fff",
        border: "3px solid rgba(0, 0, 0, 0.7)",
        "width": "200px",
        "z-index": "999999"
    }).addClass("no-print");
    
    reech_pro.click(function() {
        if (!$(this).hasClass("open")) {
            $(this).css("right", "200px");
            reech_pro_settings.css("right", "0");
            $(this).addClass("open");
        } else {
            $(this).css("right", "0");
            reech_pro_settings.css("right", "-200px");
            $(this).removeClass("open")
        }
    });

    $("body").append(reech_pro);
    $("body").append(reech_pro_settings);
});

