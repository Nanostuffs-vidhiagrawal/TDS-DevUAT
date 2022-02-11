// Search Button Click Function
function search_btn() {
  var searchInput = ".search-input";

  $(".search-btn").on("click", function () {
    $(".search-overlay").fadeIn();
    $(".search-input-btn").fadeIn();

    if ($(window).width() > 991) {
      $(this).siblings(searchInput).css({
        width: "73%",
        opacity: "1",
        transition: "0.6s",
        "border-bottom": "1px solid #D5D5D5",
      });
    } else {
      $(this).siblings(searchInput).css({
        width: "95%",
        opacity: "1",
        transition: "0.6s",
        "border-bottom": "1px solid #D5D5D5",
      });
    }
  });

  $(".search-overlay").on("click", function () {
    $(this).fadeOut();
    $(".search-input-btn").fadeOut();
    $(searchInput).css({ width: "0", opacity: "0", "border-bottom": "0" });
  });
}

// Banner Form Click Function
function banner_form_tab() {
  var textHide = $(".hero-banner-text h4");
  var tabs = ".banner_form-detail__tab";
  $(".other-info").click(function () {
    $(this).parents(".banner_form-expand__tab").hide();
    $(this)
      .parents(".banner_form-expand__tab")
      .siblings(".banner_form-expand__tab")
      .show();
  });
  $(tabs).on("click", function () {
    if ($(this).next(".banner_form-expand").length === 0) return;
    $(this).hide();
    $(this).siblings(".banner_form-detail__heading").hide();
    $(this).siblings(".banner_form-detail__tab").hide();
    $(this)
      .parents(".banner_form-detail")
      .siblings(".banner_form-detail")
      .css("display", "none");
    $(this).next().css("display", "block");

    if ($(window).width() < 1150) {
      textHide.hide();
    }
  });

  $(".other-close-tab").on("click", function () {
    $(this).parents(".banner_form-expand__tab").css("display", "none");
    $(this)
      .parents(".banner_form-expand__tab")
      .siblings(".banner_form-expand__tab")
      .css("display", "block");
  });

  $(".close-tab").on("click", function () {
    $(this).parents(".banner_form-expand").css("display", "none");
    $(".banner_form-detail__heading").css("display", "block");
    $(".banner_form-detail__tab").css("display", "block");
    $(".banner_form-detail__heading").css("display", "block");
    $(this)
      .parents(".banner_form-detail")
      .siblings(".banner_form-detail")
      .css("display", "block");

    if ($(window).width() < 1150) {
      textHide.show();
    }
  });
}

//Search Key Event
function searchKeyup() {
  $(".ui-menu .ui-menu-item .ui-menu-item-wrapper").keydown(function () {
    $(this).css("background-color", "#ffffff");
  });
  $(".ui-menu .ui-menu-item .ui-menu-item-wrapper").keyup(function () {
    $(this).css("background-color", "#ffffff");
  });
}

// other tab function
function other_input() {
  $(".other_input").on("click", function () {
    $(".other_tab").fadeIn();
  });

  $(".confirm_tenancy").on("click", function () {
    $(".tenancy_confirm").fadeIn();
  });

  $(".agree-btn").on("click", function () {
    $(this).addClass("active");
    $(this).siblings(".agree-detail").fadeIn();
    $(this)
      .parents(".agree-container")
      .siblings(".agree-container")
      .children(".agree-detail")
      .fadeOut(10);
    $(this)
      .parents(".agree-container")
      .siblings(".agree-container")
      .children(".agree-btn")
      .removeClass("active");
  });
}

// Tooltip function
function all_tooltip() {
  $('[data-toggle="tooltip"]').tooltip();
}

//How it works slider
function how_it_works() {
  $(".slider-for").slick({
    slidesToShow: 1,
    slidesToScroll: 1,
    arrows: false,
    fade: true,
    infinite: true,
    autoplay: true,
    draggable: true,
    speed: 100,
    autoplaySpeed: 2000,
    pauseOnHover: false,
    asNavFor: ".slider-nav",
  });

  $(".slider-nav").slick({
    slidesToShow: 4,
    slidesToScroll: 0,
    asNavFor: ".slider-for",
    dots: false,
    speed: 100,
    arrows: false,
    centerMode: true,
    focusOnSelect: true,
    autoplay: true,
    infinite: true,
    autoplaySpeed: 2000,
    pauseOnHover: false,
    // draggable: false,
    responsive: [
      {
        breakpoint: 767,
        settings: {
          slidesToShow: 2,
          draggable: true,
          centerMode: false,
        },
      },
      // You can unslick at a given breakpoint now by adding:
      // settings: "unslick"
      // instead of a settings object
    ],
  });
}

//deposit steps slider
// function deposit_steps() {
//     $('.deposit_steps_detail').slick({
//         slidesToShow: 1,
//         slidesToScroll: 1,
//         arrows: false,
//         fade: true,
//         infinite: false,
//         draggable: true,
//         speed: 300,
//         asNavFor: '.deposit_steps_count'
//     });

//     $('.deposit_steps_count').slick({
//         slidesToShow: 5,
//         slidesToScroll: 0,
//         asNavFor: '.deposit_steps_detail',
//         dots: false,
//         speed: 300,
//         arrows: false,
//         centerMode: true,
//         focusOnSelect: true,
//         infinite: false,
//         // draggable: false,
//         responsive: [
//             {
//               breakpoint: 767,
//               settings: {
//                 slidesToShow: 2,
//                 draggable: true,
//                 centerMode: false
//               }
//             }
//           ]
//     });
// }

//Resource Slider Function
function resource_slider() {
  $(".resource_slider").slick({
    slidesToShow: 3,
    slidesToScroll: 1,
    dots: false,
    arrows: false,
    infinite: false,
    speed: 300,
    responsive: [
      {
        breakpoint: 767,
        settings: {
          slidesToShow: 2,
          slidesToScroll: 1,
          infinite: true,
          dots: true,
        },
      },

      {
        breakpoint: 575,
        settings: {
          slidesToShow: 1,
          slidesToScroll: 1,
          infinite: true,
          dots: true,
        },
      },
    ],
  });
}

//Tag Slider Function
function tag_slider() {
  if ($(window).width() < 768) {
    $(".tag_slider").slick({
      slidesToShow: 4,
      slidesToScroll: 1,
      dots: false,
      arrows: false,
      infinite: false,
      speed: 300,

      responsive: [
        {
          breakpoint: 575,
          settings: {
            slidesToShow: 2,
            slidesToScroll: 1,
          },
        },
      ],
    });
  }
}

// Three Column Overlay SLider Function
function three_column_overlay_slider() {
  $(".three_column_overlay_slider").slick({
    slidesToShow: 3,
    slidesToScroll: 0,
    dots: false,
    arrows: false,
    infinite: false,
    speed: 300,
    centerMode: true,
    focusOnSelect: false,
    centerPadding: "0px",

    responsive: [
      {
        breakpoint: 992,
        settings: {
          slidesToShow: 2,
          draggable: true,
          centerMode: false,
          centerPadding: "25px",
        },
      },

      {
        breakpoint: 575,
        settings: {
          slidesToShow: 1,
          draggable: true,
          centerMode: true,
          centerPadding: "25px",
        },
      },
    ],
  });
}

//Switching Steps Slider Function
function switching_steps() {
  $(".switching-steps").slick({
    slidesToShow: 3,
    slidesToScroll: 0,
    dots: false,
    arrows: false,
    infinite: false,
    speed: 300,
    centerMode: true,
    focusOnSelect: false,
    centerPadding: "0px",

    responsive: [
      {
        breakpoint: 992,
        settings: {
          slidesToShow: 2,
          draggable: true,
          centerMode: false,
          centerPadding: "25px",
        },
      },

      {
        breakpoint: 767,
        settings: {
          slidesToShow: 1,
          draggable: true,
          centerMode: true,
          centerPadding: "25px",
        },
      },
    ],
  });
}

//latest Topic slider
function latest_topic() {
  $(".latest_topic_slider").slick({
    dots: true,
    arrows: false,
    infinite: false,
    speed: 300,
    slidesToShow: 2,
    slidesToScroll: 2,
    responsive: [
      {
        breakpoint: 767,
        settings: {
          slidesToShow: 1,
          slidesToScroll: 1,
          infinite: true,
          dots: true,
        },
      },
    ],
  });
}

// Play Video Function
function play_video() {
  $("#layout_video_play").click(function (e) {
    $("iframe")[0].src += "?autoplay=1";
    e.preventDefault();
    $(".overlay-picture").fadeOut();
    $(".overlay-play-btn").fadeOut();
  });
}

// Organization Details Tab
function org_slide() {
  $("#left_nav-sf-organisation-tab").on("click", function () {
    $(".org-detail-list").slideToggle();
    $(this).toggleClass("open");
  });

  $("#left_nav-sf-presonal-tab").on("click", function () {
    if ($(this).siblings().hasClass("open")) {
      $(".org-detail-list").slideUp();
      $(this).siblings().removeClass("open");
    }
  });
}

// Organization Details Scroll
function org_scroll() {
  $(".account-detail").on("click", function () {
    $("html, body").animate(
      { scrollTop: $("#account-detail").offset().top - 30 },
      1000
    );
  });

  $(".Correspondence-email").on("click", function () {
    $("html, body").animate(
      { scrollTop: $("#Correspondence-email").offset().top - 30 },
      1000
    );
  });

  $(".payment-details").on("click", function () {
    $("html, body").animate(
      { scrollTop: $("#payment-details").offset().top - 30 },
      1000
    );
  });

  $(".prescribed-info").on("click", function () {
    $("html, body").animate(
      { scrollTop: $("#prescribed-info").offset().top - 30 },
      1000
    );
  });

  $(".additional-user").on("click", function () {
    $("html, body").animate(
      { scrollTop: $("#additional-user").offset().top - 30 },
      1000
    );
  });

  $(".account-type").on("click", function () {
    $("html, body").animate(
      { scrollTop: $("#account-type").offset().top - 30 },
      1000
    );
  });

  $(".close-account").on("click", function () {
    $("html, body").animate(
      { scrollTop: $("#close-account").offset().top - 30 },
      1000
    );
  });
}

//Remove Scroll on Loader
function removeScroll() {
  if ($(".lds-dual-ring").length > 0) {
    $(".lds-dual-ring").parents("body").css("overflow", "hidden");
  }
}

// Tabs Image Function
function changeTabImg() {
  let navLink = $(".custom-tab .nav-link");
  let navLinkActive = $(".custom-tab .nav-link.active");

  navLink.mouseenter(function () {
    $(this).children(".initial-state").hide();
    $(this).children(".hover-state").show();
  });

  navLink.mouseleave(function () {
    $(this).children(".initial-state").show();
    $(this).children(".hover-state").hide();
  });
}

// Address Display Function
function addressDisplay() {
  $("#property_yes").on("click", function () {
    $(this).addClass("active");
    $(this).siblings(".learn-more").removeClass("active");
    $(".property_yes").css("display", "block");
    $(".property_no").css("display", "none");
  });

  $("#property_no").on("click", function () {
    $(this).addClass("active");
    $(this).siblings(".learn-more").removeClass("active");
    $(".property_yes").css("display", "none");
    $(".property_no").css("display", "block");
  });
}

// Address Display Function
function tenantDisplay() {
  $(".tenant_yes").on("click", function () {
    $(this).addClass("active");
    $(this).siblings(".learn-more").removeClass("active");
    $(".tenant_yes_detail").css("display", "block");
    $(".tenant_no_detail").css("display", "none");
  });

  $(".tenant_no").on("click", function () {
    $(this).addClass("active");
    $(this).siblings(".learn-more").removeClass("active");
    $(".tenant_yes_detail").css("display", "none");
    $(".tenant_no_detail").css("display", "block");
  });
}

// Enable Swwet TO US
function enable_sweet_to_us() {
  if ($(window).width() > 767) {
    $(".enable-section").on("click", function () {
      if ($(this).parents().hasClass("col-md-6")) {
        $(this).parents(".help_support-section").addClass("enable-absolute");
        $(this).parents(".row").addClass("enable-row");
        $(this)
          .parents(".col-md-6")
          .addClass("col-md-12")
          .removeClass("col-md-6");
        $(this).siblings(".more-info").show();
      }
    });
    $(".disable-section").on("click", function () {
      if ($(this).parents().hasClass("col-md-12")) {
        $(this).parents(".help_support-section").removeClass("enable-absolute");
        $(this).parents(".row").removeClass("enable-row");
        $(this)
          .parents(".col-md-12")
          .addClass("col-md-6")
          .removeClass("col-md-12")
          .find(".more-info")
          .hide();
      }
    });
  }
}

// About Us block expand
function blockExpand() {
  $(".card_grid .learn-more").on("click", function () {
    $(this).parents(".col-sm-6").removeClass("col-sm-6").addClass("col-sm-12");
    $(this).hide();
    $(this).siblings(".learn-less").show();
  });

  $(".card_grid .learn-less").on("click", function () {
    $(this).parents(".col-sm-12").removeClass("col-sm-12").addClass("col-sm-6");
    $(this).hide();
    $(this).siblings(".learn-more").show();
  });
}

// Data Table Function
function loadDataTable() {
  $("#example-1, #example-2, #example-3").DataTable({
    searching: false,
    lengthChange: true,
    ordering: true,
    fixedHeader: true,
    responsive: true,
    language: {
      paginate: {
        next: "&#8250;", // or '→'
        previous: "&#8249;", // or '←'
      },
    },
    scrollY: "450px",
    scrollX: true,
    scrollCollapse: true,
    fixedColumns: true,
  });
}

// Data Table with Checkbox Function
function tableWithCeckbox() {
  $("#table-checkbox").DataTable({
    searching: true,
    lengthChange: true,
    ordering: true,
    fixedHeader: true,
    responsive: true,
    // 'ajax': 'https://gyrocode.github.io/files/jquery-datatables/arrays_id.json',
    columnDefs: [
      {
        targets: 0,
        checkboxes: {
          selectRow: true,
        },
      },
    ],
    select: {
      style: "multi",
    },
    order: [[1, "asc"]],
    language: {
      paginate: {
        next: "&#8250;", // or '→'
        previous: "&#8249;", // or '←'
      },
    },
    fnDrawCallback: function (oSettings) {
      var totalPages = this.api().page.info().pages;
      if (totalPages == 1) {
        jQuery(".dataTables_paginate").hide();
      } else {
        jQuery(".dataTables_paginate").show();
      }
    },
    responsive: true,
  });
}

function datePicker() {
  // datepicker with dropdown [Day, Month, Year]
  $("#datepicker-ui, #datepicker-depo").datepicker({
    buttonImage: "./../assets/img/calendar-white.svg",
    buttonImageOnly: true,
    showOn: "button",
    onClose: function (dateText, inst) {
      $("#year").val(dateText.split("/")[2]);
      $("#month").val(dateText.split("/")[0]);
      $("#day").val(dateText.split("/")[1]);
    },
  });
}

function loadFormStepwithNextPrev() {
  jQuery(".form-wizard-next-btn").click(function () {
    var parentFieldset = jQuery(this).parents(".wizard-fieldset");
    var currentActiveStep = jQuery(this)
      .parents(".form-wizard")
      .find(".form-wizard-steps .active");
    var next = jQuery(this);
    var nextWizardStep = true;

    parentFieldset
      .find('.wizard-required, [required], [required = "required"]')
      .each(function (e) {
        var thisValue = jQuery(this).val();
        console.log(thisValue);
        // e.options[e.selectedIndex].value
        if (thisValue == "" || thisValue == null || thisValue == undefined) {
          jQuery(this).parents(".form-group").addClass("error");
          nextWizardStep = false;
        } else {
          jQuery(this).parents(".form-group").removeClass("error");
        }
      });
    if (nextWizardStep) {
      next.parents(".wizard-fieldset").removeClass("show", "400");
      currentActiveStep
        .removeClass("active")
        .addClass("activated")
        .next()
        .addClass("active", "400");
      next
        .parents(".wizard-fieldset")
        .next(".wizard-fieldset")
        .addClass("show", "400");
      jQuery(document)
        .find(".wizard-fieldset")
        .each(function () {
          if (jQuery(this).hasClass("show")) {
            var formAtrr = jQuery(this).attr("data-tab-content");
            jQuery(document)
              .find(".form-wizard-steps .form-wizard-step-item")
              .each(function () {
                if (jQuery(this).attr("data-attr") == formAtrr) {
                  jQuery(this).addClass("active");
                  var innerWidth = jQuery(this).innerWidth();
                  var position = jQuery(this).position();
                  jQuery(document).find(".form-wizard-step-move").css({
                    left: position.left,
                    width: innerWidth,
                  });
                } else {
                  jQuery(this).removeClass("active");
                }
              });
          }
        });
    }
  });
  //click on previous button
  jQuery(".form-wizard-previous-btn").click(function () {
    var counter = parseInt(jQuery(".wizard-counter").text());
    var prev = jQuery(this);
    var currentActiveStep = jQuery(this)
      .parents(".form-wizard")
      .find(".form-wizard-steps .active");
    prev.parents(".wizard-fieldset").removeClass("show", "400");
    prev
      .parents(".wizard-fieldset")
      .prev(".wizard-fieldset")
      .addClass("show", "400");
    currentActiveStep
      .removeClass("active")
      .prev()
      .removeClass("activated")
      .addClass("active", "400");
    jQuery(document)
      .find(".wizard-fieldset")
      .each(function () {
        if (jQuery(this).hasClass("show")) {
          var formAtrr = jQuery(this).attr("data-tab-content");
          jQuery(document)
            .find(".form-wizard-steps .form-wizard-step-item")
            .each(function () {
              if (jQuery(this).attr("data-attr") == formAtrr) {
                jQuery(this).addClass("active");
                var innerWidth = jQuery(this).innerWidth();
                var position = jQuery(this).position();
                jQuery(document).find(".form-wizard-step-move").css({
                  left: position.left,
                  width: innerWidth,
                });
              } else {
                jQuery(this).removeClass("active");
              }
            });
        }
      });
  });
}

function dynamicStepFormField() {
  var elements = document.querySelectorAll("[data-model]"),
    scope = {};
  elements.forEach(function (element) {
    //execute scope setter
    if (element.type === "text" || element.type === "textarea") {
      var propToBind = element.getAttribute("data-model");
      addScopeProp(propToBind);
      element.onkeyup = function () {
        scope[propToBind] = element.value;
      };
    }

    //bind prop to elements
    function addScopeProp(prop) {
      //add property if needed
      if (!scope.hasOwnProperty(prop)) {
        //value to populate with newvalue
        var value;
        Object.defineProperty(scope, prop, {
          set: function (newValue) {
            value = newValue;
            elements.forEach(function (element) {
              //change value to binded elements
              if (element.getAttribute("data-model") === prop) {
                if (
                  element.type &&
                  (element.type === "text" || element.type === "textarea")
                ) {
                  element.value = newValue;
                } else if (!element.type) {
                  element.innerHTML = newValue;
                }
              }
            });
          },
          get: function () {
            return value;
          },
          enumerable: true,
        });
      }
    }
  });
}

function multi_step_form_dataPicker() {
  $("#t_start_date_picker")
    .datepicker({
      todayHighlight: true,
      autoclose: true,
    })
    .on("changeDate", function (ev) {
      $("#t_startDate").change(() => {
        $('[data-model="t_start_date"]').val($("#t_startDate").val());
      });
    });

  $("#t_exp_date_picker")
    .datepicker({
      todayHighlight: true,
      autoclose: true,
    })
    .on("changeDate", function (ev) {
      $("#t_expDate").change(() => {
        $('[data-model="t_exp_date"]').val($("#t_expDate").val());
      });
    });

  $("#t_rec_date_picker")
    .datepicker({
      todayHighlight: true,
      autoclose: true,
    })
    .on("changeDate", function (ev) {
      $("#t_recDate").change(() => {
        $('[data-model="t_rec_date"]').val($("#t_recDate").val());
      });
    });
  $("#t_tds_date_picker")
    .datepicker({
      todayHighlight: true,
      autoclose: true,
    })
    .on("changeDate", function (ev) {
      $("#t_tdsDate").change(() => {
        $('[data-model="t_tds_date"]').val($("#t_tdsDate").val());
      });
    });
}

function patchMultiStepFormTenant() {
  let divBlock,
    i = 1,
    select_val,
    tenant_info_form = document.querySelector(".dynamic-form"), // form-cotainer
    patch_tenant_name = document.querySelector(".dynamic-tenant-name"); // patch name container;
  select_val = document.querySelector(".select-form"); // select box value;

  if (select_val) {
    select_val.addEventListener("change", (event) => {
      tenant_info_form.innerHTML = "";
      patch_tenant_name.innerHTML = "";
      for (i = 1; i <= event.target.value; i++) {
        divBlock = document.createElement("div");
        divBlock.setAttribute("id", "Tenant-" + i);
        tenantFormField(divBlock, i); // render DOM
        pBlock = document.createElement("p");
        pBlock.setAttribute("id", "Tenant-" + i);
        pBlock.setAttribute("class", "mb-2 px-4 py-3 repeat-tenant-name");
        pBlock.innerHTML = `<span data-model="tenant-name-${i}"></span>`;
        tenant_info_form.appendChild(divBlock);
        patch_tenant_name.appendChild(pBlock);
      }
      setTimeout(() => {
        dynamicStepFormField();
      }, 800);

      $(".landlord_yes").on("click", function () {
        $(this).addClass("active");
        $(this).siblings(".learn-more").removeClass("active");
        $(".landlord_yes_detail").css("display", "block");
        $(".landlord_no_detail").css("display", "none");
      });

      $(".landlord_no").on("click", function () {
        $(this).addClass("active");
        $(this).siblings(".learn-more").removeClass("active");
        $(".landlord_yes_detail").css("display", "none");
        $(".landlord_no_detail").css("display", "block");
      });
      
    });
  }
}

function patchMultiStepFormLandloard() {
  let landLordBlock,
    i = 1,
    landlord_info_form = document.querySelector(".dynamic-form-landlord"), // form-cotainer
    select_value = document.querySelector(".select-form-landlord"); // select box value;
  if (select_value) {
    select_value.addEventListener("change", (event) => {
      landlord_info_form.innerHTML = "";
      for (i = 1; i <= event.target.value - 1; i++) {
        landLordBlock = document.createElement("div");
        landLordBlock.setAttribute("id", "landloard-" + i);
        landlordFormField(landLordBlock, i); // render DOM
        landlord_info_form.appendChild(landLordBlock);
      }
      setTimeout(() => {
        dynamicStepFormField();
      }, 800);

      $(".tenant_yes").on("click", function () {
        $(this).addClass("active");
        $(this).siblings(".learn-more").removeClass("active");
        $(".tenant_yes_detail").css("display", "block");
        $(".tenant_no_detail").css("display", "none");
      });

      $(".tenant_no").on("click", function () {
        $(this).addClass("active");
        $(this).siblings(".learn-more").removeClass("active");
        $(".tenant_yes_detail").css("display", "none");
        $(".tenant_no_detail").css("display", "block");
      });
    });
  }
}

function previewPDFonMbl() {
  $(".mobile-toggle:not(.disabled)").on("click", function () {
    $(this).parents(".container").addClass("show-preview-on-mobile");
  });

  $(".close-pdf-mobile").on("click", function () {
    $(this).parents(".container").removeClass("show-preview-on-mobile");
  });
}

$("#month, #day, #year").change(function (e) {
  $("#datepicker-ui").datepicker(
    "setDate",
    new Date($("#year").val() - 0, $("#month").val() - 1, $("#day").val() - 0)
  );
});

$(document).ready(function () {
  search_btn();
  banner_form_tab();
  searchKeyup();
  other_input();
  all_tooltip();
  how_it_works();
  // deposit_steps();
  latest_topic();
  resource_slider();
  three_column_overlay_slider();
  tag_slider();
  switching_steps();
  play_video();
  org_slide();
  org_scroll();
  removeScroll();
  changeTabImg();
  addressDisplay();
  tenantDisplay();
  enable_sweet_to_us();
  blockExpand();
  datePicker();
  loadFormStepwithNextPrev();
  patchMultiStepFormTenant();
  patchMultiStepFormLandloard();
  multi_step_form_dataPicker();
  previewPDFonMbl();
  dynamicStepFormField();
  loadDataTable();
  tableWithCeckbox();
  jQuery.browser = {};
  (function () {
    jQuery.browser.msie = false;
    jQuery.browser.version = 0;
    if (navigator.userAgent.match(/MSIE ([0-9]+)\./)) {
      jQuery.browser.msie = true;
      jQuery.browser.version = RegExp.$1;
    }
  })();

  var textAreas = document.getElementsByTagName("textarea");
  Array.prototype.forEach.call(textAreas, function (elem) {
    elem.placeholder = elem.placeholder.replace(/\\n/g, "\n");
  });
});
