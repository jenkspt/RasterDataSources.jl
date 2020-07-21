function download_layer(l::EarthEnv, layer::Integer)
    1 ≤ layer ≤ 12 || throw(ArgumentError("The layer must be between 1 and 12"))

    path = SimpleSDMLayers.assets_path()

    root = "https://data.earthenv.org/consensus_landcover/"
    stem = l.full ? "with_DISCover/consensus_full_class_$(layer).tif" :
        "without_DISCover/Consensus_reduced_class_$(layer).tif"
    filetype = l.full ? "complete" : "partial"
    filename = "landcover_$(filetype)_$(layer).tif"

    if !isfile(joinpath(path, filename))
        layerrequest = HTTP.request("GET", root * stem)
        open(joinpath(path, filename), "w") do layerfile
            write(layerfile, String(layerrequest.body))
        end
    end

    return joinpath(path, filename)
end

function download_layer(::BioClim, layer::Integer)
    1 ≤ layer ≤ 19 || throw(ArgumentError("The layer must be between 1 and 19"))
    path = SimpleSDMLayers.assets_path()
    layer = lpad(layer, 2, "0")
    filename = "CHELSA_bio10_$(layer).tif"
    url_root = "ftp://envidatrepo.wsl.ch/uploads/chelsa/chelsa_V1/climatologies/bio/"

    filepath = joinpath(path, filename)
    if !(isfile(filepath))
        res = HTTP.request("GET", url_root * filename)
        open(filepath, "w") do f
            write(f, String(res.body))
        end
    end
    return filepath
end