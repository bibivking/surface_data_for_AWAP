;****************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;*******************************************

begin


;______ From Mark Decker's code ______
setvalues NhlGetWorkspaceObjectId()
  "wsMaximumSize" : 10000000000 ;
end setvalues
;_____________________________________


; __________________________ PLOT SETTING ____________________________
pic = "check_AWAP"
wks = gsn_open_wks("pdf",pic)
gsn_define_colormap(wks,"rainbow");"WhiteBlueGreenYellowRed")

res                    = True
res@cnFillMode         = "RasterFill"            ; Raster Mode
res@cnFillOn           = True
res@tmBorderThicknessF = 3.0
res@cnLinesOn          = False
res@gsnDraw            = True  ; Don't draw plots
res@gsnFrame           = True
res@lbLabelBarOn       = True

;filename = "/short/w35/mm3972/scripts/surface_data_for_AWAP/MD_elev_orig_std_avg-sand_AWAP_AU_landmask.nc" ;gswp3_landmask_nomissing.nc"
;filename1= "/short/w35/mm3972/scripts/surface_data_for_AWAP/MD_elev_orig_std_avg-sand_AWAP_AU_mask.nc"
filename2= "/short/w35/mm3972/data/AWAP_to_netcdf/LWdown/AWAP.LWdown.3hr.2000.nc"
; LWdown	PSurf  Qair  Rainf  SWdown  Snowf  Tair  Wind

;f = addfile (filename,"r")
;f1= addfile (filename1,"r")
f2= addfile (filename2,"r")

;var1 = f->landsea
;var2 = dim_avg_n_Wrap(f1->ssat_vec,0)
var3 = dim_avg_n_Wrap(f2->LWdown,0)

;plot = gsn_csm_contour(wks,var1,res)
;plot = gsn_csm_contour(wks,var2,res)
plot = gsn_csm_contour(wks,var3,res)

end
