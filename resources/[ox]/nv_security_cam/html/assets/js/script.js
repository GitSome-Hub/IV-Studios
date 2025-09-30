window.addEventListener('message', function(e) {
    var data = e.data
    if (data.type == "visible"){
        show_overlay(data.data)
    }
    if (data.type == "cam"){
        update_info(data.data)
    }
});

$(document).keydown(function(e) {
    if (e.key === 'Escape') {
        exit()
    }
});

function update_info(cam){
    $(".nosignal").hide(0)
    if (cam.broken){
        $(".nosignal").show(0)
    }
    $(".info h1").text(`${cam.zoneCode} #${cam.index}`)
    $(".info p").text(cam.zone)
}

function show_overlay(status){
    if (status){$("body").show()}
    else{$("body").hide()}
}

var interval;


$(".bi-sign-turn-left").on("click",function(){
    $.post("https://nv_security_cam/doCommand",JSON.stringify({type:"left"}))
})

$(".bi-sign-turn-right").on("click",function(){
    $.post("https://nv_security_cam/doCommand",JSON.stringify({type:"right"}))
})

$(".bi-caret-up-fill").on("mousedown", function(){
    interval = setInterval(function(){ $.post("https://nv_security_cam/doCommand",JSON.stringify({type:"mup"})) }, 10);
}).on("mouseup mouseleave", function(){
    clearInterval(interval);
});

$(".bi-caret-down-fill").on("mousedown", function(){
    interval = setInterval(function(){ $.post("https://nv_security_cam/doCommand",JSON.stringify({type:"mdown"}))}, 10);
}).on("mouseup mouseleave", function(){
    clearInterval(interval);
});

$(".bi-caret-left-fill").on("mousedown", function(){
    interval = setInterval(function(){ $.post("https://nv_security_cam/doCommand",JSON.stringify({type:"mleft"})) }, 10);
}).on("mouseup mouseleave", function(){
    clearInterval(interval);
});

$(".bi-caret-right-fill").on("mousedown", function(){
    interval = setInterval(function(){ $.post("https://nv_security_cam/doCommand",JSON.stringify({type:"mright"}))}, 10);
}).on("mouseup mouseleave", function(){
    clearInterval(interval);
});

$(".bi-zoom-in").on("mousedown", function(){
    interval = setInterval(function(){ $.post("https://nv_security_cam/doCommand",JSON.stringify({type:"zoomin"})) }, 10);
}).on("mouseup mouseleave", function(){
    clearInterval(interval);
});

$(".bi-zoom-out").on("mousedown", function(){
    interval = setInterval(function(){ $.post("https://nv_security_cam/doCommand",JSON.stringify({type:"zoomout"}))}, 10);
}).on("mouseup mouseleave", function(){
    clearInterval(interval);
});

$(".bi-x-lg").on("click",function(){exit()})

function exit(){
    $.post("https://nv_security_cam/exit")
}