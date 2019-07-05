;****************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;*******************************************

begin
; __________________________ PLOT SETTING ____________________________
res                    = True
res@cnFillMode         = "RasterFill"            ; Raster Mode
res@cnFillOn           = True
res@tmBorderThicknessF = 3.0
res@cnLinesOn          = False
res@gsnDraw            = True  ; Don't draw plots
res@gsnFrame           = True
res@lbLabelBarOn       = True

filename = "/short/w35/mm3972/cable/src/CABLE-AUX/offline/gridinfo_mmy_MD_elev_orig_landmask.nc" ;gswp3_landmask_nomissing.nc"
filename1= "/g/data1/wd9/MetForcing/Global/GSWP3_2017/Tair/GSWP3.BC.Tair.3hrMap.1917.nc"
filename2= "/short/w35/mm3972/cable/src/CABLE-AUX/offline/gridinfo_mmy_MD_elev_orig_mask.nc"

f = addfile (filename,"r")
f1= addfile (filename1,"r")
f2= addfile (filename2,"r")

landsea = f->landsea*1.
printVarSummary(landsea)

landsea = where( landsea .eq. 0. , 0. , 3.)

;landsea = where( landsea .eq. -9999 , 0. , 3.)

Tair = f1->Tair(0,:,:) ;*1.

land = f2->landsea*1.
land = where( land .eq. 0. , 1., 6.)


;sfc = f2->Albedo ;*1.
;sfc@_FillValue = 1.
;sfc = where( ismissing(sfc) , 1., 6.)
;sfc@_FillValue = -9999.


print("landsea")

aa = landsea - land 
aa@_FillValue = -3.
;bb = land - sfc
;print(num(aa .eq. 2))
pic = "check_map"
wks = gsn_open_wks("pdf",pic)
gsn_define_colormap(wks,"rainbow");"WhiteBlueGreenYellowRed")
plot = gsn_csm_contour(wks,aa,res)
;plot = gsn_csm_contour(wks,bb,res)
plot = gsn_csm_contour(wks,landsea,res)
plot = gsn_csm_contour(wks,Tair,res)
plot = gsn_csm_contour(wks,land,res)
end




