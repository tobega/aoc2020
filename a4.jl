abstract type Field end

struct Byr<:Field
  year
end

function isyearbetween(v, min, max)
  contains(v, r"^\d{4}$") && min <= parse(Int, v) <= max
end

function isvalid(byr::Byr)
  isyearbetween(byr.year, 1920, 2002)
end

struct Eyr<:Field
  year
end

function isvalid(eyr::Eyr)
  isyearbetween(eyr.year, 2020, 2030)
end

struct Iyr<:Field
  year
end

function isvalid(iyr::Iyr)
  isyearbetween(iyr.year, 2010, 2020)
end

struct Hgt<:Field
  height
end

function isvalid(hgt::Hgt)
  (endswith(hgt.height, "cm") && 150 <= parse(Int, hgt.height[1:end-2]) <= 193) || (endswith(hgt.height, "in") && 59 <= parse(Int, hgt.height[1:end-2]) <= 76)
end

struct Hcl<:Field
  colour
end

function isvalid(hcl::Hcl)
  contains(hcl.colour, r"^#[0-9a-f]{6}$")
end

struct Ecl<:Field
  colourcode
end

const EYE_COLOURS = ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
function isvalid(ecl::Ecl)
  in(ecl.colourcode, EYE_COLOURS)
end

struct Pid<:Field
  id
end

function isvalid(pid::Pid)
  contains(pid.id, r"^\d{9}$")
end

struct Cid<:Field
  id
end

function isvalid(cid::Cid)
  true
end

struct Passport
  fields::Vector{Field}
  Passport(s) = new(eval.([Expr(:call, Symbol(uppercasefirst(a[1])), a[2]) for a in split.(split(s, "\n"), ":")]))
end

passports = Passport.(split(replace(strip(read("a4.txt", String)), " "=>"\n"), "\n\n"))

const REQUIRED = [:Byr, :Eyr, :Iyr, :Hgt, :Hcl, :Ecl, :Pid]
function hasrequiredfields(p::Passport)
  fieldtypes = nameof.(typeof.(p.fields))
  all(r -> in(r, fieldtypes), REQUIRED)
end

part1 = count(hasrequiredfields, passports)
println("$part1")

function isvalid(passport::Passport)
  hasrequiredfields(passport) && all(isvalid, passport.fields)
end

part2 = count(isvalid, passports)
println("$part2")
