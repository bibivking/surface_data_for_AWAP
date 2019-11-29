;*******************************************
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

casename = (/\
            "GADY-CABLE_orig",\
            "GADY-CABLE_orig_std",\
            "MD_elev_orig",\
            "MD_elev_orig_std",\
            "MD_elev_orig_std_avg-sand"\
           /)

; __________________________ options ____________________________
ip_opt = "orig" ;"bilinear" ;"orig"


nml_1D = (/\
            "time","rad_dummy","patch","rad","soil","soil_depth",\
            "x","y","longitude","latitude"\
          /)
          
nml_2D = (/\
            "iveg","isoil","soil_color","rhosoil","Albedo","albedo2","landsea",\
            "sand","sand2","silt","silt2","clay","clay2","organic","organic2",\
            "hyds","bch","sfc","ssat","sucs","swilt","css","cnsd",\
            "drainage_density","drainage_dist",\
            "slope","slope_std","Sy","dtb","elevation","elevation_std",\
            "permeability","permeability_std"\
          /)
          
nml_3D = (/\
            "patchfrac",\       ;(1,lat,lon)        ;3D
            "LAI","SnowDepth",\ ;(time:12,lat,lon)
            "bch_vec","sucs_vec","ssat_vec","swilt_vec","sfc_vec","css_vec","hyds_vec",\ ; (soil:6,lat,lon)
            "rhosoil_vec","cnsd_vec","sand_vec","clay_vec","silt_vec","org_vec","watr"\
           /)
           
nml_4D = (/"SoilMoist","SoilTemp"/)         ; 4D ;(time, soil, lat, lon)


; ______________________________ Forming nc data ____________________________
fname = "/short/w35/mm3972/cable/src/CABLE-AUX/offline/gridinfo_mmy_MD_elev_orig_std_avg-sand_mask.nc"
fcp = addfile (fname,"r")

fname1 = "/short/w35/mm3972/scripts/surface_data_for_AWAP/MD_elev_orig_std_avg-sand_AWAP_AU_landmask.nc"
fcp1 = addfile (fname1,"r")
lat     = fcp1->lat
lon     = fcp1->lon

lat!0         = "latitude"
lat&latitude  = lat*1.0
lon!0         = "longitude"
lon&longitude = lon*1.0


filo = "/short/w35/mm3972/scripts/surface_data_for_AWAP/"+casename(4)+"_AWAP_AU_mask.nc"

system("/bin/rm -f " + filo)    ; remove if exists
fout  = addfile (filo, "c")     ; open output file

; explicitly declare file definition mode. Improve efficiency.
setfileoption(fout,"DefineMode",True)

; create global attributes of the file
fAtt               = True            ; assign file attributes
fAtt@title         = "converge gridinfo and elev for AU AWAP"
fAtt@source_file   = "gridinfo_mmy_MD_elev_orig_std_avg-sand_mask.nc"
fAtt@Conventions   = "None"
fAtt@creation_date = systemfunc ("date")
fileattdef( fout, fAtt )            ; copy file attributes


nlat   = 681 ;
nlon   = 841
ntime  = 12 ;
nsoil  = 6 ;
npatch = 1 ;
nrad   = 3 ;
nsdepth = 6

dimNames = (/"time", "latitude", "longitude", "soil", "patch", "rad", "soil_depth"/)
dimSizes = (/ 12   ,  nlat     ,  nlon      ,  nsoil,  npatch,  nrad,  nsdepth    /)
dimUnlim = (/ False,  False    ,  False     ,  False,  False ,  False, False       /)
filedimdef(fout,dimNames,dimSizes,dimUnlim)


;; ____________________________ nml_1D ____________________________________

; ----------- 0-5 ------------
do var_num = 0,5
  print(nml_1D(var_num))
  filevardef(fout, nml_1D(var_num),typeof(fcp->$nml_1D(var_num)$),getvardims(fcp->$nml_1D(var_num)$))
  filevarattdef(fout,nml_1D(var_num),fcp->$nml_1D(var_num)$)
  fout->$nml_1D(var_num)$ = fcp->$nml_1D(var_num)$ 
end do

; ------------ x --------------
print(nml_1D(6))
filevardef(fout, nml_1D(6),typeof(fcp->$nml_1D(6)$),getvardims(lon))
filevarattdef(fout,nml_1D(6),fcp->$nml_1D(6)$)
fout->$nml_1D(6)$ = lon

; ------------ y --------------
print(nml_1D(7))
filevardef(fout, nml_1D(7),typeof(fcp->$nml_1D(7)$),getvardims(lat))
filevarattdef(fout,nml_1D(7),fcp->$nml_1D(7)$)
fout->$nml_1D(7)$ = lat

; --------- longitude ---------
print(nml_1D(8))
filevardef(fout, nml_1D(8),typeof(fcp->$nml_1D(8)$),getvardims(lon))
filevarattdef(fout,nml_1D(8),fcp->$nml_1D(8)$)
fout->$nml_1D(8)$ = lon

; --------- latitude ---------
print(nml_1D(9))
filevardef(fout, nml_1D(9),typeof(fcp->$nml_1D(9)$),getvardims(lat))
filevarattdef(fout,nml_1D(9),fcp->$nml_1D(9)$)
fout->$nml_1D(9)$ = lat

; _______________________ nml_2D __________________________
do var_num = 0,32
   print(nml_2D(var_num)) 
   if var_num .le. 1 then
      var   = new((/681,841/),  integer)
   else
      var   = new((/681,841/),  float)
   end if
   var!0   = "latitude"
   var!1   = "longitude"
   var&latitude  = lat*1.0
   var&longitude = lon*1.0
   do x = -43.75,-10.25,0.5
      do y = 112.25,153.75,0.5
         var({x-0.25:x+0.25},{y-0.25:y+0.25}) = fcp->$nml_2D(var_num)$({x},{y})
      end do
   end do
   filevardef(fout, nml_2D(var_num),typeof(fcp->$nml_2D(var_num)$),getvardims(var))
   print(getvardims(var))
   filevarattdef(fout,nml_2D(var_num),fcp->$nml_2D(var_num)$)
   fout->$nml_2D(var_num)$ = var*1
   delete(var)
end do

; _______________________ nml_3D _______________________
; ----- 0 ------
print(nml_3D(0))
var   = new((/1,681,841/),  float)
var!0 = "patch"
var!1 = "latitude"
var!2 = "longitude"
var&patch = 1
var&latitude  = lat*1.0
var&longitude = lon*1.0
do x = -43.75,-10.25,0.5
   do y = 112.25,153.75,0.5
      var(:,{x-0.25:x+0.25},{y-0.25:y+0.25}) = fcp->$nml_3D(0)$(:,{x},{y})
   end do
end do
filevardef(fout, nml_3D(0),typeof(fcp->$nml_3D(0)$),getvardims(var))
filevarattdef(fout,nml_3D(0),fcp->$nml_3D(0)$)
fout->$nml_3D(0)$ = var*1.0
delete(var)

; ----- 1,2 ------
do var_num = 1,2
print(nml_3D(var_num))
var   = new((/12,681,841/),  float)
var!0 = "time"
var!1 = "latitude"
var!2 = "longitude"
var&time = ispan(1,12,1)
print(var&time)
var&latitude  = lat*1.0
var&longitude  = lon*1.0
printVarSummary(var)
printVarSummary(fcp->$nml_3D(var_num)$)
print("Point 1 OK")
do x = -43.75,-10.25,0.5
   do y = 112.25,153.75,0.5
      do time = 0,11
         var(time,{x-0.25:x+0.25},{y-0.25:y+0.25}) = fcp->$nml_3D(var_num)$(time,{x},{y})
      end do
   end do
end do
print("Point 2 OK")
filevardef(fout, nml_3D(var_num),typeof(fcp->$nml_3D(var_num)$),getvardims(var))
filevarattdef(fout,nml_3D(var_num),fcp->$nml_3D(var_num)$)

print("Point 3 OK")
fout->$nml_3D(var_num)$ = var*1.0

print("Point 4 OK")
delete(var)
end do

; ----- 3-16 -----
do var_num = 3,16
   print(nml_3D(var_num))
   var   = new((/6,681,841/),  float)
   var!0 = "soil_depth"
   var!1 = "latitude"
   var!2 = "longitude"
   var&soil_depth = (/0.011, 0.051, 0.157, 0.4385, 1.1855, 2/)
   var&latitude        = lat*1.0
   var&longitude        = lon*1.0
   do x = -43.75,-10.25,0.5
      do y = 112.25,153.75,0.5
         do soil_depth = 0,5
            var(soil_depth,{x-0.25:x+0.25},{y-0.25:y+0.25}) = fcp->$nml_3D(var_num)$(soil_depth,{x},{y})
         end do
      end do
   end do
   filevardef(fout, nml_3D(var_num),typeof(fcp->$nml_3D(var_num)$),getvardims(var))
   filevarattdef(fout,nml_3D(var_num),fcp->$nml_3D(var_num)$)
   fout->$nml_3D(var_num)$ = var*1.0
   delete(var)
end do

; _______________________ nml_4D _______________________
do var_num = 0,1
   print(nml_4D(var_num))
   var     = new((/12,6,681,841/),  float) ;(time, soil, lat, lon)
   var!0   = "time"
   var!1   = "soil"
   var!2   = "latitude"
   var!3   = "longitude"
   var&time= ispan(1,12,1)
   var&soil= ispan(1,6,1)
   var&latitude = lat*1.0
   var&longitude = lon*1.0
   do x = -43.75,-10.25,0.5
      do y = 112.25,153.75,0.5
         do time = 0,11
            do soil = 0,5
               var(time,soil,{x-0.25:x+0.25},{y-0.25:y+0.25}) = fcp->$nml_4D(var_num)$(time,soil,{x},{y})
            end do
         end do
      end do
   end do
   filevardef(fout, nml_4D(var_num),typeof(fcp->$nml_4D(var_num)$),getvardims(var))
   filevarattdef(fout,nml_4D(var_num),fcp->$nml_4D(var_num)$)
   fout->$nml_4D(var_num)$ = var*1.0
   delete(var)
end do

setfileoption(fout,"DefineMode",False)
print("Exit DefineMode")

; __________________________ PLOT SETTING ____________________________
pic = "check_AU_gridinfo_AWAP"
wks = gsn_open_wks("pdf",pic)
gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")

res                    = True
res@cnFillMode         = "RasterFill"            ; Raster Mode
res@cnFillOn           = True
res@tmBorderThicknessF = 3.0

res@gsnDraw            = True  ; Don't draw plots
res@gsnFrame           = True
res@lbLabelBarOn       = True
res@cnLinesOn          = False   
res@gsnAddCyclic       = False

; nml_2D
do var_num = 0,32 
   res@tiMainString = nml_2D(var_num)
   plot = gsn_csm_contour_map(wks,fout->$nml_2D(var_num)$,res)
end do

; nml_3D
do var_num = 0,16
   res@tiMainString = nml_3D(var_num)
   plot = gsn_csm_contour_map(wks,fout->$nml_3D(var_num)$(0,:,:),res)
end do

; nml_4D
do var_num = 0,1
   res@tiMainString = nml_4D(var_num)
   plot = gsn_csm_contour_map(wks,fout->$nml_4D(var_num)$(0,0,:,:),res)
end do

end 
