var currentfamily = null;
  var familymenuon = false;
  var garagemenuon = false;
  var createmenuon = false;
window.addEventListener("message", function (event) {   


   if (event.data.message == "openfamilymenu"){
 

    $('.familymenu_leftmenu').fadeOut(0);
    $('#mainmenuid').fadeIn(0);
    $('.familymenu').fadeIn(500);
    $('#familyidsi').html(event.data.familydata.name);
    $('#familyidsi2').html(event.data.familydata.name);
    $('#familyplayercountid').html(event.data.familydata.meta.members.length+' '+'PLAYER');
    insertcountoffamilyvehicles(event.data.familydata.meta);
    $('#familylevelimiz').html('0' +event.data.familydata.meta.maininfos.familylevel);
    $('#familylevelimiz2').html('0' +event.data.familydata.meta.maininfos.familylevel + ' '+'Level');
    $("#familyimagemiz").attr("src", String(event.data.familydata.image));
    $('.imagetextbeya').html(event.data.familydata.name+ " FAMILY");
     
     
   
     setupmembers(event.data.familydata.meta.members);

     setupchat(event.data.familydata.familychat,event.data.playerid);
     currentfamily = event.data.familydata;
     marketsetup(event.data.marketitems);
     setupitemss(event.data.familydata.meta.allitems);
     setupinventorys(event.data.familydata.meta.inventorys);
     setupgarages(event.data.familydata.meta.garages);
     setpermission(event.data.familydata.meta.members,event.data.playerid);
     setuptopss(event.data.familydata.meta.members);
     setupmission(event.data.familydata.meta.missions);
     requestsetuo(event.data.familydata.meta.requests);
     
     $('#ttenselect1').val(event.data.familydata.meta.staffss.inventoryaccess).change();
     $('#ttenselect2').val(event.data.familydata.meta.staffss.garageaccess).change();
    
    
     $("#settingsdekiimg").attr("src", String(event.data.familydata.image));

     
     familymenuon = true;
   }


   if (event.data.message == "refreshchat"){
    setupchat(event.data.newchat,event.data.chatplayerid);
   }

   if (event.data.message == "refreshsettings"){
    currentfamily = event.data.newdata
    setupmembers(currentfamily.meta.members);
    setpermission(currentfamily.meta.members,event.data.playerid);
    requestsetuo(currentfamily.meta.requests);
   }
   if (event.data.message == "refreshvaults"){
    currentfamily = event.data.newdata
    setupitemss(currentfamily.meta.allitems);
    setupinventorys(currentfamily.meta.inventorys);
    setupgarages(currentfamily.meta.garages);
    $('#ttenselect1').val(currentfamily.meta.staffss.inventoryaccess).change();
     $('#ttenselect2').val(currentfamily.meta.staffss.garageaccess).change();
     requestsetuo(currentfamily.meta.requests);
   }
   if (event.data.message == "refreshtoplist"){
    currentfamily = event.data.newdata
    setuptopss(currentfamily.meta.members);
   }

   if (event.data.message == "closemission"){
    $('.familymenu').fadeOut(500);
   }

   if (event.data.message == "closeinfodiv"){
    $('.familykeywarn').css("display", "none");
    $('.familykeywarn2').css("display", "none");

   }
   if (event.data.message == "openzoneinfodiv"){

    $('.familykeywarn2').css("display", "block");

   }

   

   

  //  ---------------------------------------------------------------------- GARAGE ------------------------------------------------- 

  if (event.data.message == "opengarage"){
    $('.familyvehiclelist').css("display", "block");
     insertvehicleingarage(event.data.aracdata);
     garagefamilyid = event.data.maindata;
     garageidsi = event.data.hangigarage;
    //  body.style.backgroundImage = "linear-gradient(top left, #E68121, #464242)";
     garagemenuon = true;
  }
   


  // ---------------------------------------------------------------- CHANGE NAME --------------------------------------------------------------------- 

    if (event.data.message == "openchangename"){
      $('.familymenu').fadeOut(50);
      $('.changename').fadeIn(350);



    }


    // ------------------------------------------------------------ Create part ----------------------------------------------------------------------------

    if(event.data.message == "opencreate"){
      $('.familycreate_create').fadeOut(0);
      $('.familycreate').fadeIn(500);
      $('.familycreate_list').fadeIn(0);
      createmenuon = true;
      loadfamiys(event.data.createdata);
    }

    if ( event.data.message == "notifyon"){
      $('.familynotify').fadeIn(300);
      $('#notifytext').html(event.data.notifytext);
      var spraysound = new Audio('pop.wav');
      spraysound.play();
      setTimeout(() => {
        $('.familynotify').fadeOut(300);
      }, "2000")
    }


    if (event.data.message == "updateimg"){
      currentfamily = event.data.familynew;
      $("#familyimagemiz").attr("src", String(currentfamily.image));
     $("#settingsdekiimg").attr("src", String(currentfamily.image));
    }

    if (event.data.message == "opentime"){

      $('.raidzone').css("display", "block");
      timeronbeya(event.data.raidtime);

    }

    if (event.data.message == "stopraid"){
      $('.raidzone').css("display", "none");
      stopraid(event.data.raidname);
      

    }




    if (event.data.message == "drawtexton"){
      $('.drwatext').fadeIn(300);

      $("#drawtextid").html(event.data.drawtextext);
    }


    if (event.data.message == "drawtextoff"){
      $('.drwatext').fadeOut(300);

     
    }
   

    if (event.data.message == "adminzone"){
      $('#adminzonemenu1').fadeOut(0);
      $('#adminzonemenu2').fadeOut(0);


      $('#adminzonemenu1').fadeIn(100);

      $('.adminzone').fadeIn(300);

      insertadminzone(event.data.familyzone);

    }



    if (event.data.message == "closeadminzone"){
      $('.adminzone').fadeOut(300);
    }


    if (event.data.message == "openf6menu"){
      $('.actionmain').fadeIn(300);

    }
});

function insertadminzone(data){
  
  $('#adminzonelistid').html('');

  for (const [key, value] of Object.entries(data)) {
    // console.log(key, JSON.stringify(value));
    const actionum = JSON.stringify(value)
    $('#adminzonelistid').append('<div class="adminzone_menu_1_list_item"> <div class="adminzone_menu_1_list_item_1"> <div class="adminzone_menu_1_list_item_1_text">ID</div> </div> <div class="adminzone_menu_1_list_item_1_text2">'+value.zonename+'</div> <div class="adminzone_menu_1_list_item_1_text2">vector4('+(value.zonecoord.x).toFixed(2)+','+(value.zonecoord.y).toFixed(2)+','+(value.zonecoord.z).toFixed(2)+')</div> <div class="adminzone_menu_1_list_item_1_text3"> <img src="info.svg" alt="" class = "infoclass" data-infoid ="'+value.zonename+'" > <img class = "deleteclass" data-deleteid ="'+value.zonename+'" src="delete.svg" alt=""> </div> </div>');
    $('.infoclass[data-infoid='+value.zonename+']').attr({"data-zonetten": actionum});
    $('.deleteclass[data-deleteid='+value.zonename+']').attr({"data-zonetten2": actionum});
  }

 

    


  adminzoneclick();
}


function stopraid(data){

  clearInterval(myInterval);
  $.post('https://els_family/removeraid', JSON.stringify({ 
    name:data
  }));
}


function adminzoneclick(){
  $( ".infoclass" ).each( function( i, obj ) {

    var data = $( this ).data( "zonetten" ); 



    
      $( this ).click( function() { 
        //  console.log(JSON.stringify(data))

         let copyGfGText = "vector4("+ data.zonecoord.x + "," + data.zonecoord.y + "," + data.zonecoord.z + ")";
    
         copyToClipboard(copyGfGText);
         textwrite('Coordinate copied.');

       
     
  
      
      })
  });



  $( ".deleteclass" ).each( function( i, obj ) {

    var data = $( this ).data( "zonetten2" ); 



    
      $( this ).click( function() { 
        $.post('https://els_family/deletezone', JSON.stringify({ 
          zonename : data.zonename
        }));
    
     
  
      
      })
  });






}


function copyToClipboard(text) {
    var dummy = document.createElement("textarea");
    // to avoid breaking orgain page when copying more words
    // cant copy when adding below this code
    // dummy.style.display = 'none'
    document.body.appendChild(dummy);
    //Be careful if you use texarea. setAttribute('value', value), which works with "input" does not work with "textarea". – Eduard
    dummy.value = text;
    dummy.select();
    document.execCommand("copy");
    document.body.removeChild(dummy);
}


function insertcountoffamilyvehicles(data) {
  var count = 0;
  for (let i = 0; i < data.garages.length; i++) {
  //  console.log(data.garages[i].vehicles.length)
   count = count + data.garages[i].vehicles.length
    
  }
  $('#familyplayervehicleid').html(count+ ' Vehicle');
   
}

function timeronbeya(thistime){
   count = Number(thistime);
   myInterval = setInterval(myTimer, 1000);
 
}

function myTimer() {
  if (count != 0){
  count = count - 1
  $('#timertext').html(' '+ count);
  }else{
  $('.raidzone').css("display", "none");
  $.post('https://els_family/raidnow', JSON.stringify({ }));
  clearInterval(myInterval);
  }
  }

function textwrite(text){
  $('.familynotify').fadeIn(300);
  var spraysound = new Audio('pop.wav');
    spraysound.play();
      $('#notifytext').html(text);
      setTimeout(() => {
        $('.familynotify').fadeOut(300);

      }, "2000")
}





function loadfamiys(datta){
  $('.familycreate_list_main').html('');
  for (let i = 0; i < datta.length; i++) {
    const element = datta[i];

    $('.familycreate_list_main').append('<div class="familyscard" data-familysid = "'+element.familyid+'" data-find="'+element.name+'"> <div class="familyscardimg" style="width: 70px; height: 70px;"><img src="'+element.image+'" alt="" ></div> <div class="createfamilycard1" id="denemebubeyas"> <div class="wahitisthehcreate">'+element.name+'</div> <div class="createfamilsettingicon"> </div> </div> </div>')
    
  }

  createpartfamily();
}



function requestsetuo(datta){

  $('.familymenu_main_settings_other_main').html('');
  for (let i = 0; i < datta.length; i++) {
    const element = datta[i];
    
    $('.familymenu_main_settings_other_main').append('<div class="familymenu_main_settings_other_main_item"> <div class="familymenu_main_settings_other_main_item_img"> <img src="mark.png" alt=""> </div> <div class="familymenu_main_settings_other_main_item_text">'+element.membername+'</div> <div class="familymenu_main_settings_other_main_item_button" data-requestaccept ="'+i+'"> <svg style="margin: 15px;" width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"> <path d="M20.4984 1.40625L9.50156 15.9047L3 9.40781L0 12.4078L9.99844 22.4062L24 4.40625L20.4984 1.40625Z" fill="black" fill-opacity="0.49"/> </svg> </div> </div>')
   
  }

  requestbuttons();
}

function setupmission(datta){
  $('.familymenu_rightmenu_missino_main').html('');
  for (let i = 0; i < datta.length; i++) {
    const element = datta[i];
    if (currentfamily.meta.maininfos.familylevel >= element.missionrank ){
    $('.familymenu_rightmenu_missino_main').append('<div class="familymenu_rightmenu_missino_main_item" data-tten ="'+i+'"> <div class="familymenu_rightmenu_missino_main_item_1">'+element.missioname+'</div> <div class="familymenu_rightmenu_missino_main_item_2">'+element.missiondest+'</div> <div class="familymenu_rightmenu_missino_main_item_3"> <svg width="14" height="14" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg"> <path d="M10 18.3333C5.39752 18.3333 1.66669 14.6025 1.66669 9.99996C1.66669 5.39746 5.39752 1.66663 10 1.66663C14.6025 1.66663 18.3334 5.39746 18.3334 9.99996C18.3334 14.6025 14.6025 18.3333 10 18.3333ZM10.8334 9.99996V5.83329H9.16669V11.6666H14.1667V9.99996H10.8334Z" fill="white"/> </svg> <div class="familymenu_rightmenu_missino_main_item_3_text">'+element.dailyjobcount+' Day</div> </div> </div>')
     }
  }

  missionbuttons();
}


function requestbuttons(){
//     $( ".requestcancel" ).each( function( i, obj ) {

//       var data = $( this ).data( "requestreject" ); 
   

      


      
//         $( this ).click( function() { 
//           $.post('https://els_family/rejectplayer', JSON.stringify({
//             changeid : currentfamily.familyid,
//             whichplayer:data
       
         
          
//           }));
       
    
        
//         })
//   });
  $( ".familymenu_main_settings_other_main_item_button" ).each( function( i, obj ) {

    var data2 = $( this ).data( "requestaccept" ); 




      $( this ).click( function() { 
        $.post('https://els_family/acceptplayer', JSON.stringify({
          changeid : currentfamily.familyid,
          whichplayer:data2
    
      
        
        }));
    

      
      })
    });

  
}


function createpartfamily(){
    $( ".familyscard" ).each( function( i, obj ) {

      var data = $( this ).data( "familysid" ); 



      
        $( this ).click( function() { 
          $.post('https://els_family/joinfamily', JSON.stringify({
            changeid : data
       
         
          
          }));
       
    
        
        })
  });


  
}


function missionbuttons(){
    $( ".familymenu_rightmenu_missino_main_item" ).each( function( i, obj ) {

      var data = $( this ).data( "tten" ); 



      
        $( this ).click( function() { 
          // $('.mainpart').css("display", "none");
          $.post('https://els_family/missinaccept', JSON.stringify({
            changeid : currentfamily.familyid,
            missionid : data
         
          
          }));
    
        
        })
  });


  
}


function setpermission(datta, playeridisi){

  for (let i = 0; i < datta.length; i++) {
    const element = datta[i];
   if (element.memberid == playeridisi){
      if (element.membersettings.perinv){
        
        $('#marketperm').css("display", "block");
      }else{
        $('#marketperm').css("display", "none");
      }

      if (element.membersettings.pergarage){
        
        $('#stockperm').css("display", "block");
      }else{
        $('#stockperm').css("display", "none");
      }
      if (element.membersettings.persettings){
        
        $('#settingsperm').css("display", "block");
      }else{
        $('#settingsperm').css("display", "none");
      }
      if (element.membersettings.permem){
        
        $('#memberperm').css("display", "block");
      }else{
        $('#memberperm').css("display", "none");
      }

    } 
    
  }

  // memberbuttons();
}


function insertvehicleingarage(datta){
  $('.familyvehiclelist_main_2').html('');
  for (let i = 0; i < datta.length; i++) {
    const element = datta[i];
    if (element.vehiclestatus == "in") {
    $('.familyvehiclelist_main_2').append('<div class="familyvehiclelist_main_2_item" data-vehiclesira ="'+i+'"> <div class="familyvehiclelist_main_2_item_1"> <img src="dot.svg" alt=""> </div> <div class="familyvehiclelist_main_2_item_2">'+element.vehiclename+' - '+element.vehicleplate+' - (IN)</div> </div>');

    }else{
        $('.familyvehiclelist_main_2').append('<div class="familyvehiclelist_main_2_item" data-vehiclesira ="'+i+'"> <div class="familyvehiclelist_main_2_item_1"> <img src="dot2.svg" alt=""> </div> <div class="familyvehiclelist_main_2_item_2">'+element.vehiclename+' - '+element.vehicleplate+' - (OUT)</div> </div>');

    }
   
    
  }

   vehicleclick();
}



function vehicleclick(){
    $( ".familyvehiclelist_main_2_item" ).each( function( i, obj ) {

      var data = $( this ).data( "vehiclesira" ); 



      
        $( this ).click( function() { 
          $('.familyvehiclelist').css("display", "none");
          $.post('https://els_family/vehicleout', JSON.stringify({
            changeid : garagefamilyid,
            outvehicleid : data,
            garageidsi :garageidsi
          
          }));
        
        })
  });


  
}


function setuptopss(datta){
  $('.familymenu_leftmenu_bottom_players').html('');
  for (let i = 0; i < datta.length; i++) {
    const element = datta[i];
    $('.familymenu_leftmenu_bottom_players').append('<div class="familymenu_leftmenu_bottom_players_item"> <div class="familymenu_leftmenu_bottom_players_item_1"> <div class="familymenu_leftmenu_bottom_players_item_1_textcss">#'+(i+1)+'</div> </div> <div class="familymenu_leftmenu_bottom_players_item_2"> <div class="familymenu_leftmenu_bottom_players_item_2_avatar"> <img src="'+element.memberrank+'.png" alt=""> </div> <div class="familymenu_leftmenu_bottom_players_item_1_textcss_1">'+element.membername+'</div> </div> <div class="familymenu_leftmenu_bottom_players_item_3"> <div class="familymenu_leftmenu_bottom_players_item_1_textcss_2">'+element.memberrank+'</div> </div> <div class="familymenu_leftmenu_bottom_players_item_4"> <div class="familymenu_leftmenu_bottom_players_item_1_textcss_3">'+element.membertime+'</div> </div> </div>');

    // $('#topssss').append('<tr> <td>'+element.membername+'</td> <td>'+element.memberrank+'</td> <td>'+element.membertime+' munite</td> </tr>');
    
  }

  // memberbuttons();
}


function setupgarages(datta){
  $('#garageinsertid').html('');
  for (let i = 0; i < datta.length; i++) {
    const element = datta[i];
    $('#garageinsertid').append('<div class="familymenu_stock2_main_1_1_item"> <div class="familymenu_stock2_main_1_1_item_1"> <div class="familymenu_stock2_main_1_1_item_1_text">ID</div> </div> <div class="familymenu_stock2_main_1_1_item_1_text2">GARAGE - '+element.garageid+'</div> <div class="familymenu_stock2_main_1_1_item_1_text3"> <svg  class ="refreshcoord1"  data-changerot1 = "'+i+'" width="21" height="21" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"> <path d="M21.82 15.4201L19.32 19.7501C18.83 20.6101 17.92 21.0601 17 21.0001H15V23.0001L12.5 18.5001L15 14.0001V16.0001H17.82L15.6 12.1501L19.93 9.65006L21.73 12.7701C22.25 13.5401 22.32 14.5701 21.82 15.4201ZM9.21 3.06006H14.21C15.19 3.06006 16.04 3.63006 16.45 4.45006L17.45 6.19006L19.18 5.19006L16.54 9.60006L11.39 9.69006L13.12 8.69006L11.71 6.24006L9.5 10.0901L5.16 7.59006L6.96 4.47006C7.37 3.64006 8.22 3.06006 9.21 3.06006ZM5.05 19.7601L2.55 15.4301C2.06 14.5801 2.13 13.5601 2.64 12.7901L3.64 11.0601L1.91 10.0601L7.05 10.1401L9.7 14.5601L7.97 13.5601L6.56 16.0001H11V21.0001H7.4C6.93151 21.034 6.4629 20.9357 6.04747 20.7165C5.63203 20.4973 5.28645 20.1659 5.05 19.7601Z" fill="#2798EA"/> </svg> <svg class = "deletecoord1" data-deleteinv1 = "'+i+'"  width="21" height="21" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"> <path d="M6 19C6 20.1 6.9 21 8 21H16C17.1 21 18 20.1 18 19V7H6V19ZM19 4H15.5L14.5 3H9.5L8.5 4H5V6H19V4Z" fill="#E64040"/> </svg> </div> </div>');
    
  }

   garagebuttons();
}



function setupinventorys(datta){
  $('#stockinsertid').html('');
  for (let i = 0; i < datta.length; i++) {
    const element = datta[i];
    $('#stockinsertid').append('<div class="familymenu_stock2_main_1_1_item"> <div class="familymenu_stock2_main_1_1_item_1"> <div class="familymenu_stock2_main_1_1_item_1_text">ID</div> </div> <div class="familymenu_stock2_main_1_1_item_1_text2">INVENTORY - '+element.inventoryid+'</div> <div class="familymenu_stock2_main_1_1_item_1_text3"> <svg class ="refreshcoord"  data-changerot = "'+i+'" width="21" height="21" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"> <path d="M21.82 15.4201L19.32 19.7501C18.83 20.6101 17.92 21.0601 17 21.0001H15V23.0001L12.5 18.5001L15 14.0001V16.0001H17.82L15.6 12.1501L19.93 9.65006L21.73 12.7701C22.25 13.5401 22.32 14.5701 21.82 15.4201ZM9.21 3.06006H14.21C15.19 3.06006 16.04 3.63006 16.45 4.45006L17.45 6.19006L19.18 5.19006L16.54 9.60006L11.39 9.69006L13.12 8.69006L11.71 6.24006L9.5 10.0901L5.16 7.59006L6.96 4.47006C7.37 3.64006 8.22 3.06006 9.21 3.06006ZM5.05 19.7601L2.55 15.4301C2.06 14.5801 2.13 13.5601 2.64 12.7901L3.64 11.0601L1.91 10.0601L7.05 10.1401L9.7 14.5601L7.97 13.5601L6.56 16.0001H11V21.0001H7.4C6.93151 21.034 6.4629 20.9357 6.04747 20.7165C5.63203 20.4973 5.28645 20.1659 5.05 19.7601Z" fill="#2798EA"/> </svg> <svg class = "deletecoord" data-deleteinv = "'+i+'"  style="margin-left: 5px;" width="21" height="21" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"> <path d="M6 19C6 20.1 6.9 21 8 21H16C17.1 21 18 20.1 18 19V7H6V19ZM19 4H15.5L14.5 3H9.5L8.5 4H5V6H19V4Z" fill="#E64040"/> </svg> </div> </div>');
    
  }

   inventorybuttons();
}

function setupitemss(datta){
  $('.familymenu_stock_main_1').html('');
  for (let i = 0; i < datta.length; i++) {
    const element = datta[i];
    $('.familymenu_stock_main_1').append('<div class="familymenu_stock_main_item"> <div class="familymenu_stock_main_item_bottom" data-buneee = "'+i+'" data-buneee2 = "'+element.itemname+'" data-buneee3 = "'+element.type+'"> <div class="familymenu_stock_main_item_bottom_text">Use</div> </div> <div class="familymenu_stock_main_item_top_text"> <div style="text-align:center;color: #FFF; opacity:0.6; font-family: Heebo; font-size: 12px; font-style: normal; font-weight: 500; line-height: normal;">'+element.itemlabel+'</div> </div> <div class="familymenu_stock_main_item_bottom_img"> <img src="'+element.image+'" alt=""> </div> </div>');
    
  }

  itemsbuttons();
}


function garagebuttons(){
    $( ".refreshcoord1" ).each( function( i, obj ) {

      var data = $( this ).data( "changerot1" ); 

      // console.log(data)
 

       
      
        $( this ).click( function() { 
          $('.familymenu').css('display', 'none')
          $('.familykeywarn').css('display', 'block');
          $.post('https://els_family/refreshgaragecoords', JSON.stringify({
            changeid : currentfamily.familyid,
            rfress : data
    
          }));
        
        })
  });



  $( ".deletecoord1" ).each( function( i, obj ) {

    var data = $( this ).data( "deleteinv1" ); 




      $( this ).click( function() { 
        $('.familymenu').css('display', 'none')
       
        $.post('https://els_family/deletegarage', JSON.stringify({
          changeid : currentfamily.familyid,
          deletetype : data

        }));
      
      })
   });


  
}




function inventorybuttons(){
    $( ".refreshcoord" ).each( function( i, obj ) {

      var data = $( this ).data( "changerot" ); 
 

     
      
        $( this ).click( function() { 
          $('.familymenu').css('display', 'none')
          $('.familykeywarn').css('display', 'block');

          $.post('https://els_family/refreshinventorycoords', JSON.stringify({
            changeid : currentfamily.familyid,
            rfress : data
    
          }));
        
        })
  });



  $( ".deletecoord" ).each( function( i, obj ) {

    var data = $( this ).data( "deleteinv" ); 




      $( this ).click( function() { 
        $('.familymenu').css('display', 'none')
        $.post('https://els_family/deleteinventory', JSON.stringify({
          changeid : currentfamily.familyid,
          deletetype : data

        }));
      
      })
   });


  
}

function itemsbuttons(){
    $( ".familymenu_stock_main_item_bottom" ).each( function( i, obj ) {

      var data = $( this ).data( "buneee" ); 
      var data2 = $( this ).data( "buneee2" ); 
      var data3 = $( this ).data( "buneee3" ); 

     


      
        $( this ).click( function() { 
          // console.log(data2);
          $.post('https://els_family/usingitem', JSON.stringify({
            changeid : currentfamily.familyid,
            usingitem : data,
            itemname : data2,
            itemtype : data3
          }));
        
        });
  });


  
}

function setupchat(datta, playerid){
  $('.familymenu_rightmenu_chat_main_1').html('');
 if (datta != undefined){
    if (datta.length > 0){
      
      for (let i = 0; i < datta.length; i++) {
        const element = datta[i];

        if (element.memberid == playerid){
            $('.familymenu_rightmenu_chat_main_1').append('<div class="familymenu_rightmenu_chat_main_1_item" style="float: right;"> <div class="familymenu_rightmenu_chat_main_1_item_name2">Me:</div> <div class="familymenu_rightmenu_chat_main_1_item_msg2">'+element.membermessage+'</div> </div>');
         
        }else{
         
            $('.familymenu_rightmenu_chat_main_1').append('<div class="familymenu_rightmenu_chat_main_1_item"> <div class="familymenu_rightmenu_chat_main_1_item_name">'+element.membername+':</div> <div class="familymenu_rightmenu_chat_main_1_item_msg">'+element.membermessage+'</div> </div>');
         
        }
      
        
      }

      // memberbuttons();
    }

    $(".familymenu_rightmenu_chat_main_1").stop().animate({ scrollTop: $(".familymenu_rightmenu_chat_main_1")[0].scrollHeight}, 1000);
  }

  
}


function marketsetup(datta){
  $('.familymenu_market_main').html('');
  for (let i = 0; i < datta.length; i++) {
    const element = datta[i];

    if (currentfamily.meta.maininfos.familylevel >= element.itemlevel) {
      $('.familymenu_market_main').append('<div class="familymenu_market_main_item"> <div class="familymenu_market_main_item_bottom" data-buyitem = "'+element.itemname+'"> <div class="familymenu_market_main_item_bottom_text">Buy ('+element.itemprice+'$)</div> </div> <div class="familymenu_market_main_item_top_text"> <div style="text-align:center;color: rgba(203, 197, 197, 0.8); font-family: Heebo, sans-serif; font-size: 13px; font-style: normal; font-weight: 500; line-height: normal;">'+element.itemlabel+'</div> </div> <div class="familymenu_market_main_item_bottom_img"> <img src="'+element.image+'" alt=""> </div> </div>');

    }else{
      $('.familymenu_market_main').append('<div class="familymenu_market_main_item"> <div class="familymenu_market_main_item_blur"> <div class="familymenu_market_main_item_blur_item"> <img src="lock.svg" alt="" style="width: 30px; margin-left:10px;"> <div class="familymenu_market_main_item_blur_item_txt"> Level '+element.itemlevel+' </div> </div> </div> <div class="familymenu_market_main_item_bottom" data-buyitem = "'+element.itemname+'"> <div class="familymenu_market_main_item_bottom_text">Buy ('+element.itemprice+'$)</div> </div> <div class="familymenu_market_main_item_top_text"> <div style="text-align:center;color: rgba(203, 197, 197, 0.8); font-family: Heebo, sans-serif; font-size: 13px; font-style: normal; font-weight: 500; line-height: normal;">'+element.itemlabel+'</div> </div> <div class="familymenu_market_main_item_bottom_img"> <img src="'+element.image+'" alt=""> </div> </div>');

    }
   
    
  }

  marketrbuttons();
}

function marketrbuttons(){
    $( ".familymenu_market_main_item_bottom" ).each( function( i, obj ) {

      var data = $( this ).data( "buyitem" ); 

      
        $( this ).click( function() { 
          $.post('https://els_family/buyitem', JSON.stringify({
            changeid : currentfamily.familyid,
            buyingitem : data
          }));
        
        })
  });


  
}



function setupmembers(datta){
  $('.familymenu_leftmenu_member_players').html('');
  for (let i = 0; i < datta.length; i++) {
    const element = datta[i];
    
    $('.familymenu_leftmenu_member_players').append('<div class="familymenu_leftmenu_member_item" style="margin-bottom: 6px;"> <div class="familymenu_leftmenu_bottom_players_item_1"> <div class="familymenu_leftmenu_bottom_players_item_1_textcss_4">#'+(i+1)+'</div> </div> <div class="familymenu_leftmenu_bottom_players_item_2"> <div class="familymenu_leftmenu_bottom_players_item_2_avatar"> <img src="'+element.memberrank+'.png" alt=""> </div> <div class="familymenu_leftmenu_bottom_players_item_1_textcss_5">'+element.membername+'</div> </div> <div class="familymenu_leftmenu_bottom_players_item_3"> <div class="familymenu_leftmenu_bottom_players_item_1_textcss_6">'+element.memberrank+'</div> </div> <div class="familymenu_leftmenu_member_item_button" data-memsettings = "'+i+'"> <svg style="margin: 10px;" width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"> <path d="M19.5 12C19.5 11.77 19.49 11.55 19.47 11.32L21.33 9.91C21.73 9.61 21.84 9.05 21.59 8.61L19.72 5.38C19.6001 5.16818 19.4062 5.00814 19.1754 4.93062C18.9447 4.8531 18.6935 4.86356 18.47 4.96L16.32 5.87C15.95 5.61 15.56 5.38 15.15 5.19L14.86 2.88C14.8 2.38 14.37 2 13.87 2H10.14C9.63 2 9.2 2.38 9.14 2.88L8.85 5.19C8.44 5.38 8.05 5.61 7.68 5.87L5.53 4.96C5.07 4.76 4.53 4.94 4.28 5.38L2.41 8.62C2.16 9.06 2.27 9.61 2.67 9.92L4.53 11.33C4.48855 11.779 4.48855 12.231 4.53 12.68L2.67 14.09C2.27 14.39 2.16 14.95 2.41 15.39L4.28 18.62C4.53 19.06 5.07 19.24 5.53 19.04L7.68 18.13C8.05 18.39 8.44 18.62 8.85 18.81L9.14 21.12C9.2 21.62 9.63 22 10.13 22H13.86C14.36 22 14.79 21.62 14.85 21.12L15.14 18.81C15.55 18.62 15.94 18.39 16.31 18.13L18.46 19.04C18.92 19.24 19.46 19.06 19.71 18.62L21.58 15.39C21.83 14.95 21.72 14.4 21.32 14.09L19.46 12.68C19.49 12.45 19.5 12.23 19.5 12ZM12.04 15.5C10.11 15.5 8.54 13.93 8.54 12C8.54 10.07 10.11 8.5 12.04 8.5C13.97 8.5 15.54 10.07 15.54 12C15.54 13.93 13.97 15.5 12.04 15.5Z" fill="black" fill-opacity="0.44"/> </svg> </div> </div>');

    
  }

  memberbuttons();
}


function memberbuttons(){
    $( ".familymenu_leftmenu_member_item_button" ).each( function( i, obj ) {

      var data = $( this ).data( "memsettings" ); 

      
        $( this ).click( function() { 
            insertplayersettings(data)
            currentmember = data;
        })
  });


  
}


function insertplayersettings(hangisi){

  $('#checkbox').prop('checked', currentfamily.meta.members[hangisi].membersettings.permem);
  $('#checkbox2').prop('checked', currentfamily.meta.members[hangisi].membersettings.perinv);
  $('#checkbox3').prop('checked', currentfamily.meta.members[hangisi].membersettings.pergarage);
  $('#checkbox4').prop('checked', currentfamily.meta.members[hangisi].membersettings.persettings);




  $('.memberextramenu_toppart_text').html(currentfamily.meta.members[hangisi].membername)
  $('#ttenselect').val(currentfamily.meta.members[hangisi].memberrank).change();
  $("#membersettingsrc").attr("src", String(currentfamily.meta.members[hangisi].memberrank+'.png'));
  

  $('.memberextramenu').fadeIn(300);
  
}

function topmenuclick(data){
  if (data == "main"){
      $('.familymenu_leftmenu').fadeOut(0);
      $('#mainmenuid').fadeIn(200);

  }else if (data == "member"){

      $('.familymenu_leftmenu').fadeOut(0);
      $('#membermenuid').fadeIn(200);
  }else if (data == "market"){

      $('.familymenu_leftmenu').fadeOut(0);
      $('#marketmenuid').fadeIn(200);
  }else if (data == "stock"){
    $('.familymenu_leftmenu').fadeOut(0);
    $('#stockmenuid').fadeIn(200);
  }else if (data == "setting"){
    $('.familymenu_leftmenu').fadeOut(0);
    $('#settingmenuid').fadeIn(200);

  }
}


$(document).ready(function(){
  $("#btn2").click(function(){
    $('.familymainmenu').css('display', 'none');
    $('#membersstaf').css('display', 'block');
  });

  $("#btn1").click(function(){
    $('.familymainmenu').css('display', 'none');
    $('#homestaff').css('display', 'block');
  });

  $("#btn3").click(function(){
    $('.familymainmenu').css('display', 'none');
    $('#marketstaff').css('display', 'block');
  });

  $("#btn4").click(function(){
    $('.familymainmenu').css('display', 'none');
    $('#stockstaff').css('display', 'block');
    
  });
  $(".createfamilybutton").click(function(){
    $('.createmodal').css('display', 'block');
  
  });

  $(".familycreate_list_button").click(function(){
    $('.familycreate_list').fadeOut(100);
    $('.familycreate_create').fadeIn(300);

  });

  $("#adminzonecreatepart").click(function(){
     var data1 = $('#zonewidthid').val();
     var data2 = $('#zoneheightid').val();
     var data3 = $('#zonerotateid').val();

     if (data1.length > 0 && data2.length > 0 && data3.length > 0){
      $('.adminzone').fadeOut(300);
      $.post('https://els_family/startzone', JSON.stringify({
        data1: data1,
        data2 : data2,
        data3 : data3
       }));
     }

    
    


  });


  


  $(".familycreate_create_7").click(function(){
    $('.familycreate_create').fadeOut(100);
    $('.familycreate_list').fadeIn(300);

  });

  $(".familymenu_close_t").click(function(){
    $('.familymenu').fadeOut(500);
      
  
    $.post('https://els_family/closemenu', JSON.stringify({
  
    }));

    familymenuon = false;

  });


  $(".familymenu_close_t3").click(function(){
    $('.adminzone').fadeOut(500);
      
  
    $.post('https://els_family/closemenu', JSON.stringify({
  
    }));

  

  });

  


  $(".familymenu_close_t2").click(function(){
    $('.familycreate').fadeOut(500);
      $.post('https://els_family/closemenu', JSON.stringify({
    
      }));
      createmenuon = false;

  });

  $("#gotoadminzonecreate").click(function(){
    $('#adminzonemenu1').fadeOut(100);
    $('#adminzonemenu2').fadeIn(300);

  });


  $("#adminzonebackpart").click(function(){
    $('#adminzonemenu2').fadeOut(100);
    $('#adminzonemenu1').fadeIn(300);

  });
  
  



  
  

  // $("#searchpart").click(function(){
  //   var n = $("#createsearch").val();
  
  //   $(".familyscard").each( function(){
  //      var $this = $(this);
  //      var value = $this.attr( "data-find" ).toLowerCase();
  //      console.log(value)
  //      $this.toggleClass( "hidden", !value.includes( n ) );
  //   })
  // });

  $("#createsearch").keyup(function() {
    var n = $("#createsearch").val().toLowerCase(); //convert value to lowercase for case-insensitive comparison
    $(".familyscard").each( function(){
       var $this = $(this);
       var value = $this.attr( "data-find" ).toLowerCase();
  
       $this.toggleClass( "hidden", !value.includes( n ) );
    })
  });

  $("#btn5").click(function(){
    $('.familymainmenu').css('display', 'none');
    $('#settingsstaff').css('display', 'block');
  });
  $("#button1id").click(function(){
    var playertot = $('#imagerefresh').val();
   if (JSON.stringify(playertot) != '""'){
 

    $.post('https://els_family/changeimage', JSON.stringify({
      changeid : currentfamily.familyid,
      imageurl : $('#imagerefresh').val()
    }));

    $('#imagerefresh').val('')
    }else {
      textwrite('You did not enter a value')
   }
  });

  $(".familycreate_create_6_main").click(function(){
    var playertot = $('#thisman').val();
    var playertot2 = $('#thisman2').val();
 
    if (playertot.length > 0 && playertot2.length > 0){
      

      $.post('https://els_family/newfamilycreate', JSON.stringify({
        familyname : $('#thisman').val(),
        familyimg: $('#thisman2').val()
      }));
      $('.familycreate').fadeOut(300);
      
      $('#thisman').val('')
      $('#thisman2').val('')
    }else {
      textwrite('You did not enter a value')
    
    }
  });
  $(".createmodalicon").click(function(){
  
    $('.createmodal').css('display', 'none');
    
    $('#thisman').val('')
    $('#thisman2').val('')

  });


  
  


  $("#button2id").click(function(){
    var buda =  $('#ttenselect1').val();
    var buda2 =  $('#ttenselect2').val();

    $.post('https://els_family/changeaccess', JSON.stringify({
      changeid : currentfamily.familyid,
      inventoryst : buda,
      garagest : buda2
    }));

  
  
 
  });
  
  
  
  // $(".membercardsettingicon").click(function(){
  //   $('.membersmodal').css('display', 'block');

  // });
  $(".memberextramenu_exit").click(function(){
    $('.memberextramenu').fadeOut(300);
    currentmember = null;

  });

  $("#sendmessage").click(function(){
    var playertot = $('#chantinputid').val();
   if (JSON.stringify(playertot) != '""'){
 
    var spraysound = new Audio('selection.wav');
    spraysound.play();


    
    $.post('https://els_family/informessage', JSON.stringify({
      changeid : currentfamily.familyid,
      message : $('#chantinputid').val()
    }));
    $(".familymainchatpart").stop().animate({ scrollTop: $(".familymenu_rightmenu_chat_main_1")[0].scrollHeight}, 1000);
    $('#chantinputid').val('')
  
   }
   

  });


  $("#sendmessagechangename").click(function(){
    var playertot = $('#changeeinputid').val();
   if (playertot.length > 0){
 

    $.post('https://els_family/informnewname', JSON.stringify({
      changeid : currentfamily.familyid,
      newname : $('#changeeinputid').val()
    }));
 
    $('#changeeinputid').val('')

    $('.changename').fadeOut(300);
  
   }
   

  });


  

  $("#updatemember").click(function(){
    $('.memberextramenu').fadeOut(300);
    var member = $( "#checkbox" ).prop( "checked" )
    var inv = $( "#checkbox2" ).prop( "checked" )
    var grg = $( "#checkbox3" ).prop( "checked" )
    var stt = $( "#checkbox4" ).prop( "checked" )

   var buda =  $('#ttenselect').val();


    var infoss = {"mem":member, "inv":inv, "grg" :grg, "stt":stt , "rank": buda}
    $.post('https://els_family/changemembersettings', JSON.stringify({
      changeid : currentfamily.familyid,
      changememberid : currentmember,
      infoss : infoss
    }));
    currentmember = null;
    
    textwrite('Player settings updated');
  });
  
  $("#kickmember").click(function(){
    $('.memberextramenu').fadeOut(300);


    $.post('https://els_family/kickmember', JSON.stringify({
      changeid : currentfamily.familyid,
      changememberid : currentmember

    }));
    currentmember = null;
    
    
  });
  
  


 
});


$('#thisman').keyup(function() {
  var newvalue = $('#thisman').val();
  $('.familycreate_create_3_text').html(newvalue);
});


$('#thisman2').keyup(function() {
  var newvalue = $('#thisman2').val();
  $("#createimagekismi").attr("src", String(newvalue));
 
});

$(document).keypress(
  function(event){
    if (event.which == '13') {
      event.preventDefault();
    }
});


$(document).keyup(function(e) {
  if (e.key === "Escape") { 
    if (familymenuon){
      $('.familymenu').fadeOut(500);
      
  
      $.post('https://els_family/closemenu', JSON.stringify({
    
      }));

      familymenuon = false;
    }

    if (garagemenuon){
      $('.familyvehiclelist').fadeOut(500);
      $.post('https://els_family/closemenu', JSON.stringify({
    
      }));
      garagemenuon = false;
    }


    if (createmenuon){
      $('.familycreate').fadeOut(500);
      $.post('https://els_family/closemenu', JSON.stringify({
    
      }));
      createmenuon = false;
    }
  }
});



function actionmenuclick(data){
  if (data == "getincar") {
    $.post('https://els_family/getincar', JSON.stringify({}));
  }else if (data == "getoutcar"){

    $.post('https://els_family/getoutcar', JSON.stringify({}));
  }else if (data == "ropeleg"){

    $.post('https://els_family/ropeleg', JSON.stringify({}));

  }else if (data == "tapemouth"){

    $.post('https://els_family/tapemouth', JSON.stringify({}));


  }else if (data == "moveplayer"){

    $.post('https://els_family/moveplayer', JSON.stringify({}));

  }else if (data == "releaseplayer"){

    $.post('https://els_family/releaseplayer', JSON.stringify({}));
    
  }
}



function closeaction(){
  $('.actionmain').fadeOut(300);
  $.post('https://els_family/closeaction', JSON.stringify({}));

}