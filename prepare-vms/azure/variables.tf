# Settings

variable "account" {
  default = "dog2017"
}

variable "dns_prefix" {
  default = "dog2017"
}

variable "location" {
  // default = "northeurope"
  default = "westeurope"
}

variable "azure_dns_suffix" {
    description = "Azure DNS suffix for the Public IP"
    default = "cloudapp.azure.com"
}

variable "admin_username" {
  default = [
    "admin3956",
    "admin1293",
    "admin7354",
    "admin9254",
    "admin2937",
    "admin3836",
    "admin1257",
    "admin8643",
    "admin9364",
    "admin7356",
    "admin9274",
    "admin2638",
    "admin1834",
    "admin2643",
    "admin2993",
    "admin6343",
    "admin9837",
    "admin2433",
    "admin7223",
    "admin8253",
    "admin5263",
    "admin4363",
    "admin2454",
    "admin5242",
    "admin7434",
    "admin9332",
    "admin8263",
    "admin8736",
    "admin2293",
    "admin9448"
  ]
}

variable "admin_password" {
  default = [
    "bQq&2e8tA3TH2",
    "ePJi72d2J;3jn",
    "9M/znt9CZ63sC",
    "48Egj7bV&JCC4",
    "B8BiE9u3b?A7X",
    "8Ed6ju4n7QT[n",
    "2i89KPph9,UzH",
    "E434vNXhW/r4t",
    "F;m3f4VwA64Tn",
    "H7wg9(4ko8HfD",
    "D8d72.umj3gfz",
    "NcD948D,a3QHV",
    "9b9.KwjLAr3E2",
    "pR76Mb}7d7AVx",
    "bUdNV66*av64s",
    "K9jrkP38#hb9x",
    "oin%3QdRy629Z",
    "Epk4^32rMUK9H",
    "Lac2X9BY7;uy9",
    "gx4QY8vtc4c&2",
    "tujsL.48G79ac",
    "f92gPc6nkHP*8",
    "R6jYn78VL9)wL",
    "H34bxaHD?Dc44",
    "j9A3aC(3Ybkz8",
    "3RVsyo8Q.zq34",
    "yyNA)47UT6RE2",
    "d8Bb97$p6aLmo",
    "9RRhG7@pV2w3u",
    "8LC6KPc^X3yG8"
  ]
}

variable "count" {
  type = "map"

  default = {
    windows = "1"
  }
}

variable "vm_size" {
  default = "Standard_D2_v2"
}
