layers(::Type{WorldClim{BioClim}}) = layers(BioClim)
layerkeys(T::Type{WorldClim{BioClim}}, args...) = layerkeys(BioClim, args...)

"""
    getraster(T::Type{WorldClim{BioClim}}, [layer::Union{Tuple,AbstractVector,Integer}]; res::String="10m") => Union{Tuple,AbstractVector,String}

Download [`WorldClim`](@ref) [`BioClim`](@ref) data.

# Arguments

- `layer`: `Integer` or tuple/range of `Integer` from `$(layers(BioClim))`. 
    or `Symbol`s from `$(layerkeys(BioClim))`. Without a `layer` argument, all layers
    will be downloaded, and a `NamedTuple` of paths returned.

# Keywords

- `res`: `String` chosen from $(resolutions(WorldClim{BioClim})), "10m" by default.

Returns the filepath/s of the downloaded or pre-existing files.
"""
function getraster(T::Type{WorldClim{BioClim}}, layers::Union{Tuple,Int,Symbol}; 
    res::String=defres(T)
)
    _getraster(T, layers, res)
end

_getraster(T::Type{WorldClim{BioClim}}, layers::Tuple, res) = _map_layers(T, layers, res)
_getraster(T::Type{WorldClim{BioClim}}, layer::Symbol, res) = _getraster(T, bioclim_int(layer), res)
function _getraster(T::Type{WorldClim{BioClim}}, layer::Integer, res)
    _check_layer(T, layer)
    _check_res(T, res)

    raster_path = rasterpath(T, layer; res)
    zip_path = zippath(T, layer; res)

    if !isfile(raster_path)
        _maybe_download(zipurl(T, layer; res), zip_path)
        mkpath(dirname(raster_path))
        raster_name = rastername(T, layer; res)
        zf = ZipFile.Reader(zip_path)
        write(raster_path, read(_zipfile_to_read(raster_name, zf)))
        close(zf)
    end
    return raster_path
end

# BioClim layers don't get their own folder
rasterpath(T::Type{<:WorldClim{BioClim}}, layer; kw...) =
    joinpath(rasterpath(T), rastername(T, layer; kw...))
rastername(T::Type{<:WorldClim{BioClim}}, key; res) = "wc2.1_$(res)_bio_$key.tif"
zipname(T::Type{<:WorldClim{BioClim}}, key; res) = "wc2.1_$(res)_bio.zip"
zipurl(T::Type{<:WorldClim{BioClim}}, key; res) =
    joinpath(WORLDCLIM_URI, "base", zipname(T, key; res))
zippath(T::Type{<:WorldClim{BioClim}}, key; res) =
    joinpath(rasterpath(T), "zips", zipname(T, key; res))
