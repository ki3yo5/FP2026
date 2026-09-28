$title  Food Supply Simulation in Japan applying the SWISSfoodSys Model

$onText
Readme
Build 3.0 Apr 28 2026

Specification:
Simultaneous simulation for cropping and animal production models with 18 crops, 6 processing foods, 18 feeds, 7 livestocks, 5 animal products and 2 marine products.
The objective function to minimize consists of calorie deficit and food intake deviation of 10 food groups.
The contstraints on cropping are a) arable land endowments; b) cropping month; c) fertilizer supply (constanat or variable input).
The contstraints on livestock production are total feed supply and TDN and CP balance in feed distribution for each animal.
The common constraints in production is the labor supply. The nutrient constraints on protain, 13 minerals and 13 vitamins for requirement and upper limit.

Ishikawa et al.(2026) Can Fertilizer Importing Country Feed Itself under Multiple Risks?: Development of a Nutrient-Constrained Extension of the SWISSfoodSys Model
$offText

*-----------------------------------------------------------------------------------------
* [General setting]
* set build version name:
$if not setglobal build  $setglobal build  3.0
* select data year:
$if not setglobal dataYr $setglobal dataYr 2022
* execute Monte Carlo simulation:
$if not setglobal monte  $setglobal monte  1
* check feasibility of nutrient constraint:
$if not setglobal check  $setglobal check  0
* enable gdxxrw for detailed reports:
$if not setglobal gdx2xl $setglobal gdx2xl 0

*-----------------------------------------------------------------------------------------
* [Custom scenario for single run]
* set import decline scenario (0=baseline(0%), 1=20%, 2=40%, 3=60%, 4=100%):
$if not setglobal imscn  $setglobal imscn  1
* set rate of chemical fertilizer import (any value):
$if not setglobal cfim   $setglobal cfim   0

*-----------------------------------------------------------------------------------------
* [Modle Settings]
* set nutrition constraint tier (Tier1=EAR only, Tier2=RDA and UL, Tier3=RDA/AI and UL)
$if not setglobal tier   $setglobal tier   3
* set default weight for calorie deficit in objective fuction (any value [0,1]):
$if not setglobal wval   $setglobal wval   1
* set solve statement without cropping area upper bound:
$if not setglobal unlim  $setglobal unlim  1
* set default upper limit for cropping area expansion:
$if not setglobal uval   $setglobal uval   3
* include deserted land into land endowment:
$if not setglobal dsrt   $setglobal dsrt   1
* include constraints on fertilizer element balance (set 0 if liebig = 1):
$if not setglobal fbal   $setglobal fbal   1
* include variable yield and fertilizer application (set 0 if fbal = 1):
$if not setglobal liebig $setglobal liebig 0
* set rate of no pestiside area (any value [0,100]):
$if not setglobal npe    $setglobal npe    0
* include young animals for reproduction:
$if not setglobal reprod $setglobal reprod 0
* include CP balance in feed nutrient:
$if not setglobal CP     $setglobal CP     1

*-----------------------------------------------------------------------------------------
* [Output file]
* Set suffix for file name
$setglobal SUF ""
$batinclude appendTagVal.inc tier %tier%
$batinclude appendTagVal.inc wval %wval%
$batinclude appendTag.inc unlim   %unlim%
$ifi not %unlim%==1 $batinclude appendTagVal.inc uval %uval%
$batinclude appendTag.inc fbal    %fbal%
$batinclude appendTag.inc liebig  %liebig%
$batinclude appendTagVal.inc cfim %cfim%
$batinclude appendTagVal.inc npe  %npe%
$batinclude appendTag.inc reprod  %reprod%
$batinclude appendTag.inc CP      %CP%
* name output files
$setglobal gdx_results   .\results\%build%_data%dataYr%_import%imscn%_%SUF%_results.gdx
$setglobal excel_results .\results\%build%_data%dataYr%_import%imscn%_%SUF%_results.xlsx
$setglobal gdx_results_MC   .\results\%build%_data%dataYr%_%SUF%_results_MC.gdx
$setglobal excel_results_MC .\results\%build%_data%dataYr%_%SUF%_results_MC.xlsx


$sTitle Sets
Set
* item 
    c            crops
    ap           animal products
    fe           feeds
    ls           livestocks
* food groups
    cg           crops and processed foods
    ag           animal products
* model arguments
    t            cropping month 
    r            region 
    l            land type
    p            production 
    e            fertilizer elemtnts 
    q            feed quantity 
    nf           feed nutrients 
    n            nutrient values  
    a            age 
    s            sex  
    v            requirement value
    sname        scalar value name (for data import)
* scenario
    scn          import scenario
    w            weight on calorie balance
    u            upper limit for cropping area   
    z            animal production scenario
    pattern      cropping pattern
* mapping
    mmap         crops to month
    mmap_hok
    rmap         crops to regions 
    lmap         crops to land type 
    CRL          crops to region land type pair
    ;

$gdxin sets.gdx
$load c ap fe ls cg ag t r l p e q nf n a s v sname scn w u z pattern rmap lmap mmap mmap_hok
$gdxin

* i for ingredient for processed food 
alias (c,i);

Set
* epsilon shocks for Monte Calro simulation
    mc           /s1*s10000/
* union
    g            /set.c, set.ap/
    x            /set.g, set.ls/
* mapping to land type
    paddy(c)     /rice,pwheat,pbarley,psweetp,ppotato,psoy/
    field(c)     /wheat,barley,naked,mis_grains,sweetp,potato,soy,mis_beans,veges,scane,sbeat,rapeseed/  
    orchard(c)   /mandarin,apple,mis_fruits/
    pasture(c)   /corn,sorghum/
    local(c)     /scane,sbeat/
    winter(c)    /wheat,pwheat,barley,pbarley,naked,potato,ppotato,veges,scane,rapeseed/
* aggregator for double cropping item
    total_wheat(c)  /wheat,pwheat/
    total_barley(c) /barley,pbarley/
    total_sweetp(c) /sweetp,psweetp/
    total_potato(c) /potato,ppotato/
    total_soy(c)    /soy,psoy/
* mapping to report layer group
    staple(c)    /rice,wheat,pwheat,sweetp,psweetp,potato,ppotato,soy,psoy/
    edible(c)    /rice,wheat,pwheat,barley,pbarley,naked,mis_grains,sweetp,psweetp,potato,ppotato,soy,psoy,mis_beans,veges,mandarin,apple,mis_fruits/  
    marine(c)    /fish,seaweed/
    processed(c) /starch,sugar,oil,miso,soysource,mis_foods/   
    import(g)    /rice,wheat,barley,naked,mis_grains,sweetp,potato,soy,mis_beans,veges,apple,mis_fruits,rapeseed,fish,seaweed,starch,sugar,oil,soysource,mis_foods,beef,pork,chicken,egg,milk/
* mapping to food group
    cmap(cg,c)   Crop groups to crop mapping 
                 /grain.(rice,wheat,pwheat,barley,pbarley,naked,mis_grains)
                  tuber.(sweetp,potato,psweetp,ppotato)
                  pulse.(soy,psoy,mis_beans)
                  veget.(veges)
                  fruit.(mandarin,apple,mis_fruits)
                  starch.(starch)
                  sugar.(sugar)
                  other.(oil,miso,soysource,mis_foods) /
    amap(ag,ap)  Animap product groups to animal products mapping 
                 /meat.(beef,pork,chicken)
                  egg_dairy.(egg,milk) /
    n_exclude(n) Nutrients excluded from constraints
                 /calorie, fat, carbonhydrate, ca, vb2/
    ;

* crops to region land type pair
    CRL(c,r,l) = yes$(rmap(c,r) and lmap(c,l));

Display CRL; 



$sTitle Parameters
Scalar    
    dummy             Dummy value to linearize zyield and fert            / 1e-5   /
    BIG               Large value for controlling equation                / 1e12   /
    rate_cfim         Rate % of chemical fertilizer import                / %cfim% /
    rate_npe          Rate % of no pestiside area                         / %npe%  /
    weight            Weight on calorie balance in the objective function / %wval% /
    limit             Upper bound for area expansion and feed production  / %uval% /
    ;

parameter
* data
    sval(sname)       'Scalar values (for data import)'
    data(*,p)         'Production data'  
    land_endw(r,l)    'Land endowment (1000ha)'
    land_dsrt(r,*)    'Deserted land (1000ha)'  
    edemand(c,e)      'Fertilizer element demand (each element: kg/ha)'
    esupply(*,e)      'Fertilizer element supply (each element: t)'
    fertcoef(c,e,*)   'Fertilizer input coefficients'
    head(ls)          'Number of animals      (head)'    
    fdemand(ls,nf)    'Feed nutrient demand   (TDN:kilograms per head, CP:%)'
    fsupply(ls,nf,fe) 'Feed nutrient supply   (%)'
    fconst(fe,q)      'Feed constraints       (t)'
    ldemand_c(*)      'Labor dmenad (hour/10a -> hour/1000ha)'
    ldemand_l(*)      'Labor dmenad (hour/head)'
    pop(a,s)          'Population (million head)'
    intake(a,s,n,v)   'Required daily intake of nutrients'
    nvalue(*,n)       'Nutrient value per net food 100g (unit/100g)'
    npcvalue(*,*)     'Daily nutrient supply per capita(kcal grams/capita)'
* constant
    CRT(c,r,t)        'Crops to region month pair (binary)'
    ngroup(*)         'Number of item in food group'
    stockpile(c)      'Government grain stockpile (1000t) '
    wapply(w)         'Set weight for loop operation'
    uapply(u)         'Set upper limit for loop operation'
    lsu(ls)           'Livestock unit coefficient'
    dmcoef(fe)        'Feed DM coefficient'
    pcoef(c,i)        'Output of processed food by 1 unit crop'
    acoef(ap,ls)      'Output of animal product (kg) by 1 unit livestock'
    fcoef(fe,c)       'Forage and Feed yield (MT/ha)'
    ycoef(c,l)        'Yield increase coefficient for "paddy_dry" and "field_irr"'
* scenario
    yrrate(*)         'Yield reduction rate'
    irrate(*,*)       'Import reduation rate'
    frrate(*,*)       'Feed import reduction rate'
    epsilonfood(*,*)  'Epsilon generated from the covariance matrix'
    epsilonfeed(*,*)
    epsilonfert(*,*)
    npecoef(c)        'No pestiside area yield decrease coefficent'
* converters
    tpop              'National population       (million)'
    nreq(n)           'Daily intake requirement  (kcal grams/capita)'
    nnvalue(*,n)      'Nutrient value of foods   (kcal grams/netfood gram)'
    current_intake(*) 'Current netfood intake    (grams/capita)'
    t2g(*)            'Total food to gross food'
    t2p(*)            'Total food to processing use'
    t2f(*)            'Total food to feed use'
    g2n(*)            'Gross food to net food '
    x2n(c)            'Cropping area(1000ha) to net food (grams)'
    x2nn(c,n)         'Cropping area(1000ha) to nutritive value (kcal grams)'
    x2f(c,i)          'Cropping area(1000ha) of i to processed food (grams) of c '
    x2fn(c,i,n)       'Cropping area(1000ha) of i to nutritive value (kcal grams) of c'
    x2a(ap,ls)        'Livestock head to net food (grams)'
    x2an(ap,ls,n)     'Livestock head to nutritional value (kcal grams)'
    x2fe(fe,c)        'Cropping area(1000ha) to DM base feed (MT)'
    im(*)             'Imported food (netfood)      (grams)'
    impc(*)           '              (daily intake) (grams/capita)'
    imnn(n)           '              (nutrients)    (kcal grams/capita)'
    imfeed(fe)        'Imported feed (MT)'
    imfert(e)         'Imported fertilizers (MT each element)'
    ;
    
parameter
    req_lb(n)         Lower-bound requirement by tier
    req_ub(n)         Upper-bound requirement by tier
    has_lb(n)         Indicator for active lower-bound constraint
    has_ub(n)         Indicator for active upper-bound constraint
    inv_req_lb(n)     Inverse of requirement
    ;
    
$gdxin data_%dataYr%.gdx
$load sval data land_endw land_dsrt head fdemand fsupply fconst edemand esupply fertcoef ldemand_c ldemand_l pop intake nvalue npcvalue
$gdxin

$gdxin parameters.gdx
$load ngroup stockpile wapply uapply lsu dmcoef pcoef acoef fcoef ycoef yrrate irrate frrate epsilonfood epsilonfeed epsilonfert
$gdxin

* Organic fertilizer supply = residual of current fertilizer demand - current chemical fertilizer supply 
    esupply("organic",e) = max(0, sum(c,data(c,"area")*edemand(c,e))-esupply("prod",e)-esupply("import",e) );
* Convert hour/10a -> hour/1000ha
    ldemand_c(c) = ldemand_c(c)*(10**4);
* Include deserted land into land endowment
$iftheni %dsrt%==1
    land_endw(r,"paddy_wet")  = land_endw(r,"paddy_wet")  + land_dsrt(r,"paddy_dsrt");
    land_endw(r,"field_rain") = land_endw(r,"field_rain") + land_dsrt(r,"field_dsrt");
$endif
* dairycow half of newborn calves spent to produce beef  
    acoef("beef","dairycow")      = acoef("beef","dairycow")*(0.5*head("calves")/head("dairycow"));
* dairycow of lactating to produce milk
    acoef("milk","dairycow")      = acoef("milk","dairycow")*(sval("lactating")/head("dairycow"));
* layinghens culled to produce chicken
    acoef("chicken","layinghens") = acoef("chicken","layinghens")*(sval("culled")/head("layinghens"));
* assumed fish is harvested up to the TAC limit
    data("fish","prod") = 4650;
*Convert pasture to field_rain except Hokkaido
    land_endw(r,"field_rain") $(not sameas(r,'Hokkaido')) = land_endw(r,"field_rain") + land_endw(r,"pasture");
    land_endw(r,"pasture") $(not sameas(r,'Hokkaido')) = 0;
* Save labor demand for vegetables by 50%
    ldemand_c("veges") = 0.5*ldemand_c("veges");

    CRT(c,r,t)$(not sameas(r,'Hokkaido')) = yes$mmap(c,t);
    CRT(c,"Hokkaido",t)                   = yes$mmap_hok(c,t);
    
    tpop = sum((a,s), pop(a,s));

* nutrient daily intake requirements (weighted average by sex and age group population)
    nreq(n) = sum((a,s), pop(a,s)*intake(a,s,n,"EAR"))/tpop;
    
* nutirent amount in netfood (amount/grams)
    nnvalue(g,n) = nvalue(g,n)/100;
    
* set lower bound for each tier
$ifthen %tier% == 1
* EAR only
    req_lb(n) = sum((a,s), pop(a,s) * intake(a,s,n,"EAR"))/tpop;
$elseif %tier% == 2
* RDA only
    req_lb(n) = sum((a,s), pop(a,s) * intake(a,s,n,"RDA"))/tpop;
$elseif %tier% == 3
* RDA or AI
    req_lb(n) = sum((a,s), pop(a,s) * intake(a,s,n,"RDA"))/tpop;
    req_lb(n)$(req_lb(n)=0) = sum((a,s), pop(a,s) * intake(a,s,n,"AI"))/tpop;
$endif

* setupper bound for each tier
$ifthen %tier% == 1
* no UL
    req_ub(n) = 0;
$elseif %tier% == 2
    req_ub(n) = sum((a,s), pop(a,s) * intake(a,s,n,"UL"))/tpop;
$elseif %tier% == 3
    req_ub(n) = sum((a,s), pop(a,s) * intake(a,s,n,"UL"))/tpop;
$endif
* indicator for controling n in constraint expressions
    has_lb(n) = yes$(req_lb(n) > 0 and not n_exclude(n));
    has_ub(n) = yes$(req_ub(n) > 0 and not n_exclude(n));    
* current netfood intake as reference line (grams/capita)
    current_intake(g)      = npcvalue(g,"supply");
    
* Coefficient for slack rate
    inv_req_lb(n) = 0;
    inv_req_lb(n)$has_lb(n) = 1 / req_lb(n);

* total production to gross food, processing use, feed use and netfood supply (yield coefficient)
    t2g(g)       = data(g,"gross")/data(g,"total");
    t2p(g)       = data(g,"processing")/data(g,"total");
* adjust the rates of processing use
    t2p("rice")  = 1;
    t2p("soy")   = 18/data("soy","prod");
    t2p("psoy")  = 18/data("psoy","prod");
    t2p("scane") = 1;
    t2p("sbeat") = 1;
    t2p("rapeseed") = 1;
* to this line
    t2f(g)       = data(g,"feed")/data(g,"total");
    g2n(g)       = data(g,"g2n")/100;

* cropping area/livestock head to the netfood and nutrient value (netfood or nutrient amount per 1000ha/head)
    x2n(c)       = data(c,"yield")*t2g(c)*g2n(c)*(10**9);
    x2nn(c,n)    = x2n(c)*nnvalue(c,n);
    x2f(c,i)     = data(i,"yield")*t2p(i)*pcoef(c,i)*(10**9);
    x2fn(c,i,n)  = x2f(c,i)*nnvalue(c,n);
    x2a(ap,ls)   = acoef(ap,ls)*g2n(ap)*1000;
    x2an(ap,ls,n)= x2a(ap,ls)*nnvalue(ap,n)*0.8;
    x2fe(fe,c)   = fcoef(fe,c)*dmcoef(fe)*(10**3);

* Alternate x2n and x2nn to include "processing" into netfood for staple food group
    x2n(c) $staple(c) = data(c,"yield")*(data(c,"gross")+data(c,"processing"))/data(c,"total")*g2n(c)*(10**9);
    x2nn(c,n) $staple(c) = x2n(c)*nnvalue(c,n);

* imported food, daily intake and nutrient value
    im(g) $import(g)   = (1-irrate(g,'scn%imscn%'))*data(g,"import")*t2g(g)*g2n(g)*(10**9) $import(g);
    impc(g) $import(g) = im(g)/(tpop*(10**6)*365) $import(g);
    imnn(n)            = sum(g, impc(g)*nnvalue(g,n) $import(g));
    
* imported feed
    imfeed(fe) = (1-frrate(fe,'scn%imscn%'))*fconst(fe,"import");

* imported fertilizers  
    imfert(e)  = (1+rate_cfim/100)*(esupply("prod",e)+esupply("import",e));
    
* yield decline coefficient by setting no pestiside area  
    npecoef(c) = 1-yrrate(c)*rate_npe/100;

Display CRT, esupply, tpop, req_lb, req_ub, current_intake, imnn;



$sTitle Variables
Variable
* base
    xrlcrop(c,r,l)       'Cropping area (1000ha)'
    xcrop(c)             'Cropping area (1000ha)'
    xlive(ls)            'Head of animal ls'
    yfeed(ls,fe)         'Distribution of feed j to animal ls (MT)'
    zyield(*)            'Effective yield by Liebigs law (MT/ha)'
    fert(c,e)            'Fertilizer application per area (kg/ha)'
* first
    eled(e)              'Fertilizer element demand (MT)'
    eles(e)              'Fertilizer element supply (MT)'    
    labd_c               'Labor demand by crop      (bil. h)'
    labd_ls              'Labor demand by livestock (bil. h)'    
    tdnd(ls)             'TDN demand by livestock (MT)'
    tdns(ls)             'TDN supply to livestock (MT)'
    cpd(ls)              'CP demand by livestock  (MT)'
    cps(ls)              'CP supply to livestock  (MT)'
    dms(fe)              'DM supply               (MT)'
* second
    nnpotential_c(c,n)   'Potential nutrition intake from crops (kcal or grams/capita)'
    nnpotential_f(c,n)   'Potential nutrition intake from processed foods (kcal or grams/capita)'
    nnpotential_l(ap,n)  'Potential nutrition intake from animal products (kcal or grams/capita)'
    nnpotential(n)
    slack_lb(n)          'Nutrient shortfall'
    slack_rate(n)        'Relative nutrient shortfall'
    cal_def              'Calorie deficit rate (kcal change/capita)'
    dpotential_c(c)      'Potential netfood intake from crops (grams/capita)'
    dpotential_f(c)      'Potential netfood intake from processed foods (grams/capita)'
    dpotential_l(ap)     'Potential netfood intake from animal products (grams/capita)'
    cdev_pos(cg)         'Positive deviation from current food intake by group'
    cdev_neg(cg)         'Negative deviation from current food intake by group'
    adev_pos(ag)
    adev_neg(ag)
    avr_dev              'Average deviation rate of food intake (grams change/capita)'
*third
    target               'Target value'
    slack_obj            'Total nutrient shortfall objective'
    ;

Positive Variable xrlcrop, xcrop, xlive, yfeed, zyield, fert, cal_def, cdev_pos, cdev_neg, adev_pos, adev_neg, slack_lb, slack_rate;

* set upper limit of fertilizer application adjusted equivalent to data(c,"yield")
    fert.up(c,e) = fertcoef(c,e,"max");



$sTitle Equations
Equation
* cropping constraints   
    link                 'xrlcrop to xcrop link by summation'    
    landbal              'Monthly land balance on each land type (1000ha)'
    areamax_y            'Area upper bound on paddy crops   (1000ha)'
    areamax_u            'Area upper bound on upland crops  (1000ha)'
    areamax_p            'Area upper bound on pasture crops (1000ha)'
    areamax_o            'Area upper bound on orchard       (1000ha)'
    areamax_l            'Area upper bound on local crops   (1000ha)'
    areamax_wheat        'Area upper bound on wheat and pwheat (1000ha)'
    areamax_barley       '                    barley and pbarley'
    areamax_sweetp       '                    sweetp and psweetp'
    areamax_potato       '                    potato and ppotato'
    areamax_soy          '                    soy and psoy'
    Liebig               'Effective yield by Liebigs law of minimum (MT/ha)'
    Liebigbal            'Fertilizer element balance　(MT each element)'
    eledemand            'Fertilizer element demand  (MT each element)'
    elesupply            'Fertilizer element supply  (MT each element)'
    elebal               'Fertilizer element balance (MT each element)'
* common constraints
    labdemand_c          'Total labor demand by crop      (bil. hour)'
    labdemand_l          'Total labor demand by livestock (bil. hour)' 
    labbal               'Total labor balance             (bil. hour)'
* animal production constraints
    tdndemand            'TDN demand by animal ls'
    tdnsupply            'TDN supply for animal ls by feed fe'
    tdnbal               'TDN balance'    
    cpdemand             'CP demand by animal ls'
    cpdemand_low         'CP demand by animal ls (underestimate)'
    cpdemand_high        'CP demand by animal ls (overestimate)'
    cpsupply             'CP supply for animal ls'
    cpbal                'CP balance'
    dmsupply             'Feed supply (constant + import + crop byproducts) (dry matter MT)'
    distbal              'Feed distribution balance'
    distbal_stock        'Feed distribution balance with feed grain stockpile'
    bredbal              'Livestock breeding balance'
    dairyoxrep           'Reproduction rate of dairy ox per mother dairycow'
    heiferrep            'Reproduction rate of heifer per mother dairycow'
    calfrep              'Reproduction rate of calves per mother dairycow'
* nutrient balance constraints
    nutpet_c             'Potential nutrition supply (grams or kcal/capita)'
    nutpet_f
    nutpet_l
    nutpet
    nutrient_lb          'Lower bound of daily intake requirement'
    nutrient_ub          'Upper bound of daily intake requirement'
    nutrient_lb_relax(n)
    slack_rate_def(n)
    slack_obj_def
* calorie and netfood supply calculation
    caloriebal           'Calorie deficit rate'
    dietpet_c            'Potential netfood supply (grams/capita)'
    dietpet_f
    dietpet_l
    cg_deviation         'Deviation from current food intake'
    ag_deviation
    avr_deviation        'Average deviation'
* objective functions
    objective            'Objective function evaluated as rate of shortage'
    ;


*-----------------------------------------------------------------------------------------
* cropping constraints  
    link(c)..             sum((r,l)$CRL(c,r,l), xrlcrop(c,r,l)) =e= xcrop(c);    
    landbal(t,r,l)..      sum(c$CRL(c,r,l), xrlcrop(c,r,l) * CRT(c,r,t)) =l= land_endw(r,l);

    areamax_y(c)..        xcrop(c) $ paddy(c)   =l= limit*data(c,"area") $ paddy(c);
    areamax_u(c)..        xcrop(c) $ field(c)   =l= limit*data(c,"area") $ field(c);
    areamax_p(c)..        xcrop(c) $ pasture(c) =l= limit*data(c,"area") $ pasture(c);
    areamax_o(c)..        xcrop(c) $ orchard(c) =l=       data(c,"area") $ orchard(c);
    areamax_l(c)..        xcrop(c) $ local(c)   =l=       data(c,"area") $ local(c);
    areamax_wheat..       sum(c $total_wheat(c), xcrop(c)) =l= limit*data("wheat","area");
    areamax_barley..      sum(c $total_barley(c),xcrop(c)) =l= limit*data("barley","area");
    areamax_sweetp..      sum(c $total_sweetp(c),xcrop(c)) =l= limit*data("sweetp","area");
    areamax_potato..      sum(c $total_potato(c),xcrop(c)) =l= limit*data("potato","area");
    areamax_soy..         sum(c $total_soy(c),   xcrop(c)) =l= limit*data("soy","area");

    eledemand(e)..        eled(e)  =e= sum(c, xcrop(c)*edemand(c,e));
    elesupply(e)..        eles(e)  =e= imfert(e) + esupply("organic",e);
    elebal(e)..           eled(e)  =l= eles(e);
    
*   Liebig's Law of the Minimum yield(c) = min_e[a(c,e) + b(c,e)*fert(c,e)] is executed as yield(c) =l= a(c,e) + b(c,e)*fert(c,e) (∀e)
*   Maximize production in the objective function being executed also maximize yield(c) as much as possible.
*   Since the above inequality must hold for all e, yield(c) corresponds to the “minimum value” of the potential yield for the scarsiest element.    
    Liebig(c,e)..         zyield(c) =l= fertcoef(c,e,"intercept") + fertcoef(c,e,"slope")*fert(c,e);    
    Liebigbal(e)..        sum(c, xcrop(c)*fert(c,e)) =l= eles(e);

*-----------------------------------------------------------------------------------------
* common constraints    
    labdemand_c..         labd_c   =e= sum(c, xcrop(c)*ldemand_c(c)) /(10**9);
    labdemand_l..         labd_ls  =e= sum(ls,xlive(ls)*ldemand_l(ls))/(10**9);
    labbal..              labd_c + labd_ls  =l= sval("lsupply");

*-----------------------------------------------------------------------------------------
* animal production constraints
    tdndemand(ls)..       tdnd(ls) =e= xlive(ls)*fdemand(ls,"tdn")/1000;
    tdnsupply(ls)..       tdns(ls) =e= sum(fe, yfeed(ls,fe)*fsupply(ls,"tdn",fe)/100);
    tdnbal(ls)..          tdnd(ls) =l= tdns(ls);
    cpdemand(ls)..        cpd(ls)  =e= tdnd(ls)*fdemand(ls,"cp_mid")/100;
    cpdemand_low(ls)..    cpd(ls)  =e= tdnd(ls)*fdemand(ls,"cp_low")/100;
    cpdemand_high(ls)..   cpd(ls)  =e= tdnd(ls)*fdemand(ls,"cp_high")/100;
    cpsupply(ls)..        cps(ls)  =e= sum(fe, yfeed(ls,fe)*fsupply(ls,"cp",fe)/100);
    cpbal(ls)..           cpd(ls)  =l= cps(ls);
    dmsupply(fe)..        dms(fe)  =e= fconst(fe,"const")+imfeed(fe)+sum(c, xcrop(c)*x2fe(fe,c));
    distbal(fe)..         dms(fe)  =g= sum(ls, yfeed(ls,fe));
    distbal_stock(fe)..   dms(fe)  =g= sum(ls, yfeed(ls,fe))-fconst(fe,"stock");
    bredbal(ls)..         xlive(ls) =l= limit*head(ls);    
    dairyoxrep..          xlive("dairyox") =e= head("dairyox")*xlive("dairycow")/head("dairycow");
    heiferrep..           xlive("heifer")  =e= head("heifer") *xlive("dairycow")/head("dairycow");
    calfrep..             xlive("calves")  =e= head("calves") *xlive("dairycow")/head("dairycow");

*-----------------------------------------------------------------------------------------
* nutrient balance constraints
    nutpet_c(c,n)..       nnpotential_c(c,n) =e= sum((r,l)$CRL(c,r,l), xrlcrop(c,r,l)*x2nn(c,n)*ycoef(c,l)
$ifi %liebig%==1                                                                      *zyield(c)/data(c,"yield")
                                                 )/(tpop*(10**6)*365);

    nutpet_f(c,n)..       nnpotential_f(c,n) =e= sum((i,r,l)$CRL(i,r,l), xrlcrop(i,r,l)*x2fn(c,i,n)*ycoef(i,l)
$ifi %liebig%==1                                                                        *zyield(i)/data(i,"yield")
                                                 )/(tpop*(10**6)*365);
    
    nutpet_l(ap,n)..      nnpotential_l(ap,n) =e= sum(ls, xlive(ls)*x2an(ap,ls,n))/(tpop*(10**6)*365);

    nutpet(n)..           nnpotential(n) =e= sum(c$edible(c),nnpotential_c(c,n))
                                           + sum(c$processed(c),nnpotential_f(c,n))
                                           + sum(ap,nnpotential_l(ap,n))
                                           + sum(c$marine(c),data(c,"net")*nnvalue(c,n)*(10**9)/(tpop*(10**6)*365));

    nutrient_lb(n)$has_lb(n)..  imnn(n)+nnpotential(n) =g= req_lb(n);
    nutrient_ub(n)$has_ub(n)..  imnn(n)+nnpotential(n) =l= req_ub(n);
    nutrient_lb_relax(n)..      imnn(n)+nnpotential(n) + slack_lb(n) =g= req_lb(n) * has_lb(n);
    slack_rate_def(n)..         slack_rate(n) =e= slack_lb(n) * inv_req_lb(n);

*-----------------------------------------------------------------------------------------
* calorie and netfood supply calculation
*   Add a “very small linear term” to the objective function to avoid the saddle point solutions (all zero) in the liebig component.                                                                                                         
    caloriebal..          cal_def =e= (nreq("calorie")-imnn("calorie")-nnpotential("calorie"))/nreq("calorie")
$ifi %liebig%==1                       -sum(c, zyield(c))*dummy - sum((c,e), fert(c,e))*dummy
                          ;

    dietpet_c(c)..        dpotential_c(c) =e= sum((r,l)$CRL(c,r,l), xrlcrop(c,r,l)*x2n(c)*ycoef(c,l)
$ifi %liebig%==1                                                                  *zyield(c)/data(c,"yield")
                                                  )/(tpop*(10**6)*365);
    
    dietpet_f(c)..        dpotential_f(c) =e= sum((i,r,l)$CRL(i,r,l), xrlcrop(i,r,l)*x2f(c,i)*ycoef(i,l)
$ifi %liebig%==1                                                                    *zyield(i)/data(i,"yield")
                                                  )/(tpop*(10**6)*365);

    dietpet_l(ap)..       dpotential_l(ap) =e= sum(ls, xlive(ls)*x2a(ap,ls))/(tpop*(10**6)*365);

*   Decompose deviation to dev_pos (for sufficient products) or dev_neg (for insufficient products)
    cg_deviation(cg)..    sum(c $cmap(cg,c),   dpotential_c(c)+dpotential_f(c)+impc(c) -current_intake(c) ) =e= cdev_pos(cg)-cdev_neg(cg);
    ag_deviation(ag)..    sum(ap $amap(ag,ap), dpotential_l(ap)               +impc(ap)-current_intake(ap)) =e= adev_pos(ag)-adev_neg(ag);
    
    avr_deviation..       avr_dev =e= (  sum(cg, (cdev_pos(cg)+cdev_neg(cg))/sum(c $cmap(cg,c),current_intake(c)))
                                       + sum(ag, (adev_pos(ag)+adev_neg(ag))/sum(ap $amap(ag,ap),current_intake(ap)))
                                       )/10;

*-----------------------------------------------------------------------------------------
* objective function
    objective..           target    =e= weight*cal_def + (1-weight)*avr_dev;
    slack_obj_def..       slack_obj =e= sum(n$has_lb(n), slack_rate(n));



$sTitle Model definition and solve
    Model crop_constraint    / link,landbal,areamax_o,areamax_l,labdemand_c,labdemand_l,labbal
$ifi %fbal%==1                 eledemand,elesupply,elebal
$ifi %liebig%==1               elesupply,Liebig,Liebigbal
                             /;
    Model area_max           / areamax_y,areamax_u,areamax_p,areamax_wheat,areamax_barley,areamax_sweetp,areamax_potato,areamax_soy /;
    Model animal_constraint  / tdndemand,tdnsupply,tdnbal,dmsupply, distbal, bredbal
$ifi %CP%==1                   cpdemand,cpsupply,cpbal
$ifi %reprod%==1               dairyoxrep,heiferrep,calfrep
                             /;
    Model nutrient_constraint/ nutrient_lb, nutrient_ub /;
    Model balance            / nutpet_c,nutpet_f,nutpet_l,nutpet,caloriebal,dietpet_c,dietpet_f,dietpet_l,cg_deviation,ag_deviation,avr_deviation /;
* Standard solution
    Model standard           / crop_constraint + area_max + animal_constraint + nutrient_constraint + balance + objective /;
* Solution without expansion upper bound
    Model unlimited          / standard - area_max /;
* Relaxed solution for infeasible scenario
    Model relax              / standard - nutrient_lb - objective + nutrient_lb_relax + slack_rate_def + slack_obj_def /;


* test run
* do not change
    solve standard minimizing target using nlp ;

Display xrlcrop.l, xcrop.l, xlive.l, yfeed.l, dms.l
$ifi %liebig%==1 zyield.l, fert.l
        landbal.m, elebal.m, labbal.m, nutrient_lb.m, nutrient_ub.m
        nnpotential.l, cdev_pos.l, cdev_neg.l, adev_pos.l, adev_neg.l, cal_def.l, avr_dev.l, target.l ;

$ontext
Parameter
    result_target(scn)
    result_import(n,scn);

loop(scn,

    im(g) $import(g)   = (1-irrate(g,scn))*data(g,"import")*t2g(g)*g2n(g)*(10**9) $import(g);
    impc(g) $import(g) = im(g)/(tpop*(10**6)*365) $import(g);
    imnn(n)            = sum(g, impc(g)*nnvalue(g,n) $import(g));
    
    solve standard minimizing target using nlp ;

    result_target(scn) = target.l;
    result_import(n,scn) = imnn(n);

);
Display result_target, result_import;
$offtext

Parameter
    result_target(mc)              Target value
    result_cal_def(mc)             Calorie deficit rate
    result_avr_dev(mc)             Average deviation rate
    feasible(mc)                   Feasible solution (1 if the the solution is Globally Optimal)
    
    nutient_supply(mc,n)    Nutrient supply 
    nutrient_ratio(mc,n)    Nutrient supply ratio to requirement
    
    cg_supply(mc,cg)        Netfood supply (gram)
    ag_supply(mc,ag)
    production_crop(mc,c)   Production index: Cropping area (1000ha)
    production_live(mc,ls)  Production index: Head of animal
    
    marginal_landbal(mc,t,r,l)  Shadow price of land
    marginal_elebal(mc,e)       Shadow price of fertilizer 
    marginal_labbal(mc)         Shadow price of labor
    marginal_nutrient_lb(mc,n)  Shadow price of nutrient requirement
    
    result_slack_lb(mc,n)        Slack value of infeasible nutrient constraint
    result_slack_rate(mc,n)      Slack rate to requirement
    result_slack_obj(mc)
    ;
    
    result_slack_lb(mc,n)   = 0;
    result_slack_rate(mc,n) = 0;
    result_slack_obj(mc)    = 0;

if(%monte%,

loop(mc,

    im(g) $import(g)   = (1+epsilonfood(g,mc))*data(g,"import")*t2g(g)*g2n(g)*(10**9) $import(g);
    impc(g) $import(g) = im(g)/(tpop*(10**6)*365) $import(g);
    imnn(n)            = sum(g, impc(g)*nnvalue(g,n) $import(g));
    imfeed(fe)         = (1+epsilonfeed(fe,mc))*fconst(fe,"import");
    imfert(e)          = (1+epsilonfert(e,mc))*(esupply("prod",e)+esupply("import",e));
    
    solve standard minimizing target using nlp ;

    result_target(mc)  = target.l;
    result_cal_def(mc) = cal_def.l;
    result_avr_dev(mc) = avr_dev.l;
    feasible(mc)       = 0;
    feasible(mc)       = 1$(standard.modelstat = 1);
    
    nutient_supply(mc,n)   = imnn(n)+nnpotential.l(n);
    nutrient_ratio(mc,n)$has_lb(n)   = (imnn(n)+nnpotential.l(n))/req_lb(n);
    cg_supply(mc,cg)       = sum(c $cmap(cg,c),   dpotential_c.l(c)+dpotential_f.l(c)+impc(c));
    ag_supply(mc,ag)       = sum(ap $amap(ag,ap), dpotential_l.l(ap)+impc(ap));
    
    production_crop(mc,c)  = xcrop.l(c);
    production_live(mc,ls) = xlive.l(ls);

    marginal_landbal(mc,t,r,l) = landbal.m(t,r,l);
    marginal_elebal(mc,e)      = elebal.m(e); 
    marginal_labbal(mc)        = labbal.m;
    marginal_nutrient_lb(mc,n) = nutrient_lb.m(n);
    
* Only for infeasible case solve relaxed model
    if(feasible(mc) = 0,

        slack_lb.l(n)   = 0;
        slack_rate.l(n) = 0;
        slack_obj.l     = 0;

        solve relax minimizing slack_obj using lp;

        result_slack_lb(mc,n)   = slack_lb.l(n);
        result_slack_rate(mc,n) = slack_rate.l(n);
        result_slack_obj(mc)    = slack_obj.l;
    );

);

);



$sTitle Check feasibility of nutrient_constraint
alias(n,nnn);

set nn(n) current nutrient;

variable check;

equation def;

def..
    check =e= sum(nn, nnpotential(nn));

model checknut / crop_constraint + area_max + animal_constraint + balance + def/;

parameter
    max_nutrient(n)          'The maximum available amount of nutrient (the solution of maximization problem "checknut")'
    nutrient_gap(n)          'The gap between the maximum available amount of nutrient and requirement'
    feasible_nutrient(n)     'Take 1 if the maximum available amount of nutrient is larger than requirement, otherwise 0'
    ;

if(%check%,

loop(nnn$has_lb(nnn),

    nn(n) = no;
    nn(nnn) = yes;

    solve checknut maximizing check using nlp;

    max_nutrient(nnn) = check.l;
    nutrient_gap(nnn) = max_nutrient(nnn) - req_lb(nnn);

    feasible_nutrient(nnn) = 0;
    feasible_nutrient(nnn)$(max_nutrient(nnn) >= req_lb(nnn)) = 1;

    nn(nnn) = no;
);
display req_lb, max_nutrient, nutrient_gap, feasible_nutrient;

);



$sTitle Export Results
Parameter
    report(mc,*)
    report_nutrient(mc,*,*)
    report_slack(mc,*,*)
    ;
    
    report(mc,"target_value")       = result_target(mc);
    report(mc,"calorie_deficit")    = result_cal_def(mc);
    report(mc,"averager_deviation") = result_avr_dev(mc);
    report(mc,"feasibility")        = feasible(mc);
    
    report_nutrient(mc,"nutient_supply",n) = nutient_supply(mc,n);
    report_nutrient(mc,"nutrient_ratio",n) = nutrient_ratio(mc,n);
    
    report_slack(mc,"slack_obj","obj")  = result_slack_obj(mc);
    report_slack(mc,"slack_lb",n)   = result_slack_lb(mc,n);
    report_slack(mc,"slack_rate",n) = result_slack_rate(mc,n);


if(%monte%,

Execute_Unload '%gdx_results_MC%',
    report, report_nutrient, report_slack
    cg_supply, ag_supply, production_crop, production_live    
    marginal_landbal, marginal_elebal, marginal_labbal, marginal_nutrient_lb;
    
execute 'gdxxrw %gdx_results_MC% o=%excel_results_MC% par=report rng=report!A1 rdim=1 cdim=1'
execute 'gdxxrw %gdx_results_MC% o=%excel_results_MC% par=report_nutrient rng=report_nutrient!A1 rdim=1 cdim=2'
execute 'gdxxrw %gdx_results_MC% o=%excel_results_MC% par=report_slack rng=report_slack!A1 rdim=1 cdim=2'

if(%gdx2xl%,
execute 'gdxxrw %gdx_results_MC% o=%excel_results_MC% par=cg_supply rng=cg_supply!A1 rdim=1 cdim=1'
execute 'gdxxrw %gdx_results_MC% o=%excel_results_MC% par=ag_supply rng=ag_supply!A1 rdim=1 cdim=1'
execute 'gdxxrw %gdx_results_MC% o=%excel_results_MC% par=production_crop rng=production_crop!A1 rdim=1 cdim=1'
execute 'gdxxrw %gdx_results_MC% o=%excel_results_MC% par=production_live rng=production_live!A1 rdim=1 cdim=1'
execute 'gdxxrw %gdx_results_MC% o=%excel_results_MC% par=marginal_landbal rng=marginal_landbal!A1 rdim=1 cdim=3'
execute 'gdxxrw %gdx_results_MC% o=%excel_results_MC% par=marginal_elebal rng=marginal_elebal!A1 rdim=1 cdim=1'
execute 'gdxxrw %gdx_results_MC% o=%excel_results_MC% par=marginal_labbal rng=marginal_labbal!A1 rdim=1'
execute 'gdxxrw %gdx_results_MC% o=%excel_results_MC% par=marginal_nutrient_lb rng=marginal_nutrient_lb!A1 rdim=1 cdim=1'
);

);