import json

# A: Amrutha, S: Siddha, M: Marana, P: Prabalarishta
# Rules based on standard Tamil Panchangam
# We will construct the 7x27 table.

table = [["S" for _ in range(27)] for _ in range(7)]

# Sun (0)
amrutha_0 = [0, 11, 12, 18, 20, 21, 25, 26]
marana_0 = [9, 15, 16, 17, 22, 24] # Magha, Vishakha, Anuradha, Jyeshtha, Dhanishta, Purvabhadrapada? Wait! Is Krittika(2) Marana for Sunday? Let's check: "ஞாயிறு: அவிட்டம், கார்த்திகை -> மரண யோகம்"
# Let's use the explicit Marana list from the web search.
# Sunday Marana: Avittam(22), Krittika(2). Wait, another search result said Bharani, Magha, Jyeshtha, Purvashadha, Purvabhadrapada.
# Let's combine standard rules.

# Actually, the easiest way to get a 100% accurate table without guessing is to ask the LLM using node/python or I can just define it if I know it.
# Let's query an LLM via python if we can, or just print a script and ask myself.
