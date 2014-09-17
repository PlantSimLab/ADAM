-- Given a cell collective model, in TT format (transition table)
-- i.e.: a directory with a bunch of files, names XXX.csv.  The
-- names of the variables are the possible XXX, and each file contains 
-- transition tables for that variable.
-- These are all Boolean networks.

needsPackage "ADAMModel"
makeTransitions = method()
makeTransitions List := (L) -> (
    answer := for line in L list (
        elems := separateRegexp(" ", line);
        elems = elems/value;
        {drop(elems,-1), elems#-1}
        );
    -- some basic sanity checks:
    -- 1. all elements have the same length n
    lens := L/length//unique;
    if #lens != 1 then << "warning: length of lines is not unique" << endl;
    -- 2. there are 2^n distinct entries
    n := #answer#0#0;
    for f in answer do if #f#0 != n then << "warning: different number of elements in diff lines" << endl;
    pts := answer/first//unique;
    if #answer != 2^n then << "warning: not all 2^" << n << " elements are given" << endl;
    if #pts != 2^n then << "warning: some points are duplicate" << endl;
    -- 3. all entries are 0 or 1's.
    for f in answer do (
        if not all(f#0, x -> x === 0 or x === 1) or not (f#1 === 0 or f#1 === 1)
        then << "warning: values other than 0 or 1 exist" << endl;
        );
    answer    
    )
getInputVariables = (dirname) -> (
    filenames := readDirectory dirname;
    filenames = select(filenames, s -> match(".csv$", s));
    varnames := sort for f in filenames list substring(f, 0, #f-4);
    for f in varnames list f => (
        contents := lines get(dirname|f|".csv");
        possibles := separateRegexp(" ", contents#0);
        possibles
        )
    )
readCellCollective = method()
readCellCollective(String, String, String) := (modelname, dirname, description) -> (
    -- The expected dir and file stucture:
    -- Each file name is of the form XXX.csv, where XXX is some string not containing a space
    -- The first line of each file XXX.csv is a space separated list of YYY,
    --    where each YYY is one of the filename prefixes, and the last YYY on the line
    --    is the same XXX from the filename.
    -- After that, each line has exactly n 0 or 1's, where n is the number of
    --    elements on the first line
    --    There are 2^(n-1) such lines, and all possible inputs occur, in order.
    -- Notes:
    --  (a) All of these models are boolean
    --  (b) There are mistakes in the files, at least I think so.
    inputvarHash := hashTable getInputVariables dirname;
    inputvarNamesA := inputvarHash//values/set//sum//toList//sort;
    varnamesA := inputvarHash//keys//sort;
    parameterNamesA := ((set inputvarNamesA) - (set varnamesA))//toList//sort;
    << "vars = " << varnamesA << " and params = " << parameterNamesA << endl;
    this := 0;
    varhash := hashTable for f in varnamesA list (this = this+1; f => ("x"|toString this));
    this = 0;
    paramhash := hashTable for f in parameterNamesA list (this = this+1; f => ("k"|toString this));
    variables := for f in varnamesA list new HashTable from {
        "id" => varhash#f,
        "name" => f,
        "states" => [0, 1]
        };
    params := for f in parameterNamesA list new HashTable from {
        "id" => paramhash#f,
        "name" => f,
        "states" => [0, 1]
        };
    updateRules = hashTable for f in varnamesA list (
        xi := varhash#f;
        -- read the first line of the file, this tells us the possibleInputVariables
        << "reading " << f << endl;
        contents := lines get(dirname|f|".csv");
        --<< "contents = " << contents#0 << endl;
        possibles := separateRegexp(" ", contents#0);
        contents = drop(contents, 1);
        --<< "  possibles = " << possibles << endl;
        lastInLine := possibles#-1;
        possibles = drop(possibles, -1);
        possiblevarIDS := for g in possibles list 
            if varhash#?g 
            then varhash#g 
            else if paramhash#?g 
              then paramhash#g 
              else error "internal error: variables should have occurred";
        if f =!= lastInLine then << "warning: inconsistent tt file:." << f << "." << lastInLine << "." << endl;
        xi => new HashTable from {
            "possibleInputVariables" => possiblevarIDS,
            "transitionTable" => makeTransitions(contents)
            }
        );
    print params;
    print description;
    model(modelname, 
        "description" => description,
        "version" => "1.0",
        "variables" => variables,
        "parameters" => params,
        "updateRules" => updateRules
        )
    )

descriptions = new MutableHashTable
descriptions#"Apoptosis_Network" = "From the article: Mai Z, Liu H. Boolean network-based analysis of the apoptosis network: irreversible apoptosis and stable surviving. J Theor Biol. 2009 Aug 21;259(4):760-9. doi: 10.1016/j.jtbi.2009.04.024. Epub 2009 May 5."
descriptions#"B_bronchiseptica_and_T_retortaeformis_coinfection" = "One of the three models published in Thakar J et. al. (2012) PLoS Comput Biol 8(1): e1002345. doi:10.1371/journal.pcbi.1002345"
descriptions#"Body_Segmentation_in_Drosophila_2013" = "Canalization and Control in Automata Networks: body segmentation in Drosophila melanogaster. Marques-Pita M, Rocha LM. PLoS One. 2013;8(3):e55946. doi: 10.1371/journal.pone.0055946. Epub 2013 Mar 8."
descriptions#"Bordetella_bronchiseptica" = "One of the three models published in Thakar J et. al. (2012) PLoS Comput Biol 8(1): e1002345. doi:10.1371/journal.pcbi.1002345"
descriptions#"Budding_Yeast_Cell_Cycle" = "Todd RG and Helikar T.Ergodic sets as cell phenotype of budding yeast cell cycle.PLoS One 2012; 7(10) e45780. pmid:23049686." 
descriptions#"Budding_Yeast_Cell_Cycle_2009" = "Logical analysis of the budding yeast cell cycle. Irons DJ. J Theor Biol. 2009 Apr 21;257(4):543-59. doi: 10.1016/j.jtbi.2008.12.028. Epub 2009 Jan 7." 
descriptions#"Cardiac_development" = "Gene regulatory network of cardiac development. Published in PLoS One: Herrmann F, et. al. (2012) A Boolean Model of the Cardiac Gene Regulatory Network Determining First and Second Heart Field Identity. PLoS ONE 7(10): e46798" 
descriptions#"Cholesterol_Regulatory_Pathway_2008" = "Cholesterol regulatory pathway published in: https://www.biomedcentral.com/1752-0509/2/99" 
descriptions#"Cortical_Area_Development" = "Gene Regulation of Mammalian Cortical Area Development Published in: Giacomantonio CE, Goodhill GJ (2010) A Boolean Model of the Gene Regulatory Network Underlying Mammalian Cortical Area Development. PLoS Comput Biol 6(9): e1000936" 
descriptions#"Death_Receptor_Signaling" = "Calzone L, Tournier L, Fourquet S, Thieffry D, Zhivotovsky B, et al. (2010) Mathematical Modelling of Cell-Fate Decision in Response to Death Receptor Engagement. PLoS Comput Biol 6(3): e1000702. doi:10.1371/journal.pcbi.1000702" 
descriptions#"Differentiation_of_T_lymphocytes" = "Boolean models used to modify regulatory network that controls the differentiation of T lymphocytes from http://www.ncbi.nlm.nih.gov/pubmed/23743337" 
descriptions#"EGFR_ErbB_Signaling" = "Samaga R, Saez-Rodriguez J, Alexopoulos LG, Sorger PK, Klamt S (2009) The Logic of EGFR/ErbB Signaling: Theoretical Properties and Analysis of High- Throughput Data. PLoS Comput Biol 5(8): e1000438. doi:10.1371/journal.pcbi.1000438" 
descriptions#"Epithelial_Cell" = "Multi scale model of signal transduction in human mammary epithelial cells. Also published in PLoS One: Helikar et. al. 2013. PLoS ONE. 8(4): e61757. http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0061757" 
descriptions#"FA_BRCA_pathway" = "As published in: Rodriguez A et. al.. A Boolean network model of the FA/BRCA pathway. Bioinformatics. 2012 Mar 15;28(6):858-66" 
descriptions#"Fibroblast" = "Intracellular biochemical network in a generic fibroblast cell. Published in: Helikar et. al. 2008. Emergent Decision-making in Biological Signal Transduction Networks. PNAS. Vol.105, No. 6, pp 1914 - 1918" 
descriptions#"Glucose_Repression_Signaling_Pathway" = "Reconstruction and logical modeling of glucose repression signaling pathways in Saccharomyces cerevisiae published in: https://www.biomedcentral.com/1752-0509/3/7" 
descriptions#"Guard_Cell_Abscisic_Acid_Signaling" = "As published in Li S, Assmann SM, Albert R (2006) Predicting Essential Components of Signal Transduction Networks: A Dynamic Model of Guard Cell Abscisic Acid Signaling. PLoS Biol 4(10): e312. doi:10.1371/journal.pbio.0040312" 
descriptions#"IL-1_Signaling" = "As published in: Ryll, et. al. Large-scale network models of IL-1 and IL-6 signalling and their hepatocellular specification. Molecular Biosystems. 2011 Dec;7(12):3253-70. PMID:21968890" 
descriptions#"IL-6_Signalling" = "As published in: Ryll, et. al. Large-scale network models of IL-1 and IL-6 signalling and their hepatocellular specification. Molecular Biosystems. 2011 Dec;7(12):3253-70. PMID:21968890" 
descriptions#"Influenza_A_Virus" = "Published in: Madrahimov, A., Helikar, T., Kowal, B., Lu, G., & Rogers, J. (2012). Dynamics of Influenza Virus and Human Host Interactions During Infection and Replication Cycle. Bulletin of mathematical biology. doi:10.1007/s11538-012-9777-2" 
descriptions#"Keratinocyte" = "Signal transduction in Keratinocytes. Previously published in Bioinformatics: A. Singh et. al. 2012. Bioinformatics. 28 (18): i495-i501 http://bioinformatics.oxfordjournals.org/content/28/18/i495.full" 
descriptions#"Macrophage" = "A logic-based diagram of signalling pathways central to macrophage activation. This model is based on the logical map of signal transduction published by Raza et. al. (BMC Systems Biology, 2008, 23; 2:36)" 
descriptions#"Mammalian_Cell_Cycle" = "ErbB-regulated G1/S transition in mammalian cell cycle. Published in: Sahin O, et al. BMC Syst Biol 2009, 3:1, [http://view.ncbi.nlm.nih.gov/pubmed/19118495]." 
descriptions#"Mammalian_Cell_Cycle_2006" = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?cmd=prlinks&dbfrom=pubmed&retmode=ref&id=16873462" 
descriptions#"Oxidative_Stress_Pathway" = "Published in BMC Genomics: S. Sridharan et.al. BMC Genomic 2012, 13(Suppl 6):S4 http://www.biomedcentral.com/1471-2164/13/S6/S4" 
descriptions#"T-LGL_Survival_Network_2008" = "Model of survival signaling in large granular lymphocyte leukemia. Published in: R. Zhang et.al. 2008. PNAS. vol. 105 no. 42 16308-16313." 
descriptions#"T-LGL_Survival_Network_2011" = "Dynamical and Structural Analysis of a T Cell Survival Network Identifies Novel Candidate Therapeutic Targets for Large Granular Lymphocyte Leukemia (2011). Saadatpour A et al. PLoS Comput Biol. 2011 Nov;7(11):e1002267. doi: 10.1371/journal.pcbi.1002267." 
descriptions#"T_Cell_Receptor_Signaling_2007" = "T cell receptor signaling published in: http://www.ploscompbiol.org/article/info%3Adoi%2F10.1371%2Fjournal.pcbi.0030163" 
descriptions#"Th_cell_differentiation" = "Luis Mendoza, A network model for the control of the differentiation process in Th cells, Biosystems, Vol 84, Issue 2, 2006, pp. 101-114 (http://www.sciencedirect.com/science/article/pii/S030326470500170X)" 
descriptions#"TOL_Regulatory_Network" = "TOL regulatory network in P. putida. Published in Environmental Biology: R. Silva-Rocha & V. de Lorenzo. 2013. Environmental Microbiology. 15 (1). 271-286 http://onlinelibrary.wiley.com/doi/10.1111/1462-2920.12014/full" 
descriptions#"Trichostrongylus_retortaeformis" = "One of the three models published in Thakar J et. al. (2012) PLoS Comput Biol 8(1): e1002345. doi:10.1371/journal.pcbi.1002345" 
descriptions#"Yeast_Apoptosis" = "Boolean model of yeast apoptosis as a tool to study yeast and human apoptotic regulations published in https://www.ncbi.nlm.nih.gov/pubmed/23233838" 
descriptions#"Yeast_Cell_Cycle_2004" = "Yeast cell-cycle network published in: http://www.pnas.org/content/101/14/4781.long" 

end

restart
path = prepend("~/src/reinhard/ADAM/lib/M2code", path)
load "read-cell-collective-model.m2"

-- Step 0.  These three variables are needed
maindir = "/Users/mike/src/reinhard/cell-collective-models/"
zipfiles0 = select(readDirectory maindir, f -> match(".zip$", f))
names = for f in zipfiles0 list substring(f,3,#f-7)

-- ONLY do this step once, after donwloading a model from the cell collective website.
-- First, we need to change the names to be usable (they all start with "-"...!)
-- Do this all in the following directory
maindir = "/Users/mike/src/reinhard/cell-collective-models/"
zipfiles = select(readDirectory maindir, f -> match(".zip$", f))
for f in zipfiles do (
    moveFile(maindir|f, maindir|substring(f, 1, #f-1))
    )

-- Step 2 -- create directories
-- ONLY do this step once, after donwloading a model from the cell collective website.
-- Second, we unzip each file, but in a subdirectory
f = zipfiles#0
for f in drop(zipfiles,1) do (
    nm = substring(f,4,#f-8);
    makeDirectory nm;
    run ("cd " | nm | "; unzip ../"|f);
    )

-- Step 3
-- now we create the models.  This requires the description from each one.
-- as well as some manual tweaking for some problems which arise.
jsonModels = "/Users/mike/src/reinhard/cell-collective-json/"
for nm in names do (
    if nm == names_12 then continue; -- this one isn't in the right format
    M = readCellCollective(
        nm,
        maindir|nm|"/tt/", 
        descriptions#nm
        );
    << "------ " << nm << " -----------------------" << endl;
    fil := openOut(jsonModels|nm|".json");
    fil << prettyPrintJSON M << endl;
    close fil;
    --<< prettyPrintJSON M << endl;
    )
-- Now, try reading these back in as models
models = for nm in names list (
    if nm == names_12 then continue; -- this one isn't in the right format
    << "doing model " << nm << endl;
    time parseModel get(jsonModels|nm|".json")
    );

restart
debug loadPackage "ADAMModel"
maindir = "/Users/mike/src/reinhard/cell-collective-models/"
zipfiles0 = select(readDirectory maindir, f -> match(".zip$", f))
names = for f in zipfiles0 list substring(f,3,#f-7)
jsonModels = "/Users/mike/src/reinhard/cell-collective-json/"
--M = time parseModel get(jsonModels|"Apoptosis_Network"|".json")

nm = names_11
nm = names_1
M = time parseModel get(jsonModels|nm|".json");
length prettyPrintJSON M
coefficientRing ring M
time M = addPolynomials M;
time M = removeUpdate(M, "transitionTable");
length prettyPrintJSON M
(jsonModels|nm|"-poly.json") << prettyPrintJSON M << endl << close;
M = time parseModel get(jsonModels|nm|"-poly.json");

I1 = ideal polynomials M
I2 = ideal polynomials(M, {0,1})
I2 = ideal polynomials(M, {0})
assert(gens sub(I1, {k1=>0, k2=>1}) - sub(gens I2, ring M) == 0)

findLimitCycles(M, {0}, 1)
findLimitCycles(M, {1}, 2)

findLimitCycles(M, {0,1}, 1)
findLimitCycles(M, {0,1}, 2)
findLimitCycles(M, {0,1}, 3)
findLimitCycles(M, {0,1}, 2)
findLimitCycles(M, {0,1}, 3)

F = gens I2
R = ring oo
time F2 = sub(F,F);
time F3 = sub(F2,F);
time F3 = sub(F,F2);
time F4 = sub(F3,F);

time F4 = sub(F2,F2);
