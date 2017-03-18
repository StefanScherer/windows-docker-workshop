variable "admin_password" {
  description = "Windows Administrator password to login as."
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

variable "key_name" {
  description = "Name of the SSH keypair to use in AWS."
  default = "terraform"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default = "eu-central-1"
}

# Microsoft Windows Server 2016 Base with Containers
variable "aws_amis" {
  default = {
    eu-central-1 = "ami-7fee2210"
  }
}
