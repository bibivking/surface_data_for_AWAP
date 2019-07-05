;****************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;*******************************************

;______ From Mark Decker's code ______
setvalues NhlGetWorkspaceObjectId()
  "wsMaximumSize" : 5000000000 ;
end setvalues
;_____________________________________

begin
; __________________________ PLOT SETTING ____________________________
pic = "check_landmask"
wks = gsn_open_wks("pdf",pic)
gsn_define_colormap(wks,"rainbow");"WhiteBlueGreenYellowRed")

res                    = True
res@cnFillMode         = "RasterFill"            ; Raster Mode
res@cnFillOn           = True
res@tmBorderThicknessF = 3.0

res@gsnDraw            = True  ; Don't draw plots
res@gsnFrame           = True
res@lbLabelBarOn       = True

; __________________________ Preparing ____________________________
system("rm /short/w35/mm3972/cable/src/CABLE-AUX/offline/gswp3_landmask_nomissing_mmy.nc")
system("cp /short/w35/mm3972/cable/src/CABLE-AUX/offline/gswp3_landmask_nomissing.nc /short/w35/mm3972/cable/src/CABLE-AUX/offline/gswp3_landmask_nomissing_mmy.nc")
system("chmod 777 /short/w35/mm3972/cable/src/CABLE-AUX/offline/gswp3_landmask_nomissing_mmy.nc")
system("ls -lt /short/w35/mm3972/cable/src/CABLE-AUX/offline/gswp3_landmask_nomissing_mmy.nc")

filename = "/short/w35/mm3972/cable/src/CABLE-AUX/offline/gswp3_landmask_nomissing_mmy.nc"
filename1 = "/short/w35/mm3972/cable/src/CABLE-AUX/offline/gridinfo_mmy_GADY-CABLE_orig_std_mask.nc"

print("openfile")

f1 = addfile (filename1,"r")
landsea = f1->landsea
delete(f1)
printVarSummary(landsea)




f  = addfile (filename,"w")

printVarSummary(f->landsea)
print("plotting")

;plot = gsn_csm_contour(wks,landsea,res)
;plot = gsn_csm_contour(wks,f->landsea,res)
;landsea = f->landsea
f->landsea = landsea

print("start to plot")

plot = gsn_csm_contour(wks,f->landsea,res)
plot = gsn_csm_contour(wks,(f->landsea - landsea),res)

end
