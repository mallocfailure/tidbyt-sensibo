"""
Applet: Sensibo Elements
Summary: Displays data from Sensibo Elements
Description: Displays data from Sensibo Elements
Author: George
"""

load("render.star", "render")
load("schema.star", "schema")
load("http.star", "http")
load("math.star", "math")
load("humanize.star", "humanize")
load("cache.star", "cache")


SENSIBO_URL = "https://home.sensibo.com/api/v2/pods/YOURSENSIBO?fields=*&apiKey=YOURKEY"

white_color="#FFFFFF" # white
red_color="#BF0000" # red
orange_color="#FFA500"
sensibo_color="#24B999" # sensibo
temp1_color="#FFFFFF"
temp2_color="#FFFFFF"
temp3_color="#FFFFFF"

# variable for hot temp, switches to red font
hot_temp = 74
high_tvoc = 1500
low_tvoc = 500
high_co=2000
low_co=1000
high_pm=75
low_pm=75
high_etoh=10
low_etoh=20
high_iaq=150
low_iaq=100

TTL_SEC=60

def main(config):


    tvoc_cached = cache.get("tvoc")
    if tvoc_cached != None:
#      print("Cache hit, displaying cached data.")
      tvoc = cache.get("tvoc")
      co = cache.get("co")
      pm = cache.get("pm")
      etoh = cache.get("etoh")
      iaq = cache.get("iaq")
      temp = cache.get("temp")
      humidity = cache.get("humidity")
    else:
 #     print("Cache miss, fetching data.")
      rep = http.get(SENSIBO_URL)
      if rep.status_code != 200:
        fail("Sensibo request failed with status %d", rep.status_code)
      tvoc = rep.json()["result"]["measurements"]["tvoc"]
      co = rep.json()["result"]["measurements"]["co2"]
      pm_rep = rep.json()["result"]["measurements"]["pm25"]
      etoh_rep = rep.json()["result"]["measurements"]["etoh"]
      iaq_rep = rep.json()["result"]["measurements"]["iaq"]
      temp_rep = rep.json()["result"]["measurements"]["temperature"]
      humid_rep = rep.json()["result"]["measurements"]["humidity"]
      pm = humanize.float("#.##", float(pm_rep))
      etoh = humanize.float("#.##", float(etoh_rep))
      iaq = humanize.float("#.##", float(iaq_rep))
      temp = (temp_rep * (9/5)) + 32
      temp = humanize.float("#.#", float(temp))
      cache.set("tvoc", str(int(tvoc)), ttl_seconds=TTL_SEC)
      cache.set("co", str(int(co)), ttl_seconds=TTL_SEC)
      cache.set("pm", pm, ttl_seconds=TTL_SEC)
      cache.set("etoh", etoh, ttl_seconds=TTL_SEC)
      cache.set("iaq", iaq, ttl_seconds=TTL_SEC)
      cache.set("temp", str(temp), ttl_seconds=TTL_SEC)

    tvoc_color = white_color
    if int(tvoc) > high_tvoc:
       tvoc_color = red_color
    elif int(tvoc) > low_tvoc:
       tvoc_color = orange_color
    else:
       tvoc_color = sensibo_color

    co_color = white_color
    if int(co) > high_co:
       co_color = red_color
    elif int(co) > low_co:
       co_color = orange_color
    else:
       co_color = sensibo_color

    pm_color = white_color
    if float(pm) > high_pm:
       pm_color = red_color
    elif float(pm) > low_pm:
       pm_color = orange_color
    else:
       pm_color = sensibo_color

    etoh_color = white_color
    if float(etoh) > high_etoh:
       etoh_color = red_color
    elif float(etoh) > low_etoh:
       etoh_color = orange_color
    else:
       etoh_color = sensibo_color

    iaq_color = white_color
    if float(iaq) > high_iaq:
       iaq_color = red_color
    elif float(iaq) > low_iaq:
       iaq_color = orange_color
    else:
       iaq_color = sensibo_color


    return render.Root(
        child = render.Column(
           children=[
              render.Text("co2 " + str(int(co)), color=co_color, font="tom-thumb"),
              render.Text("tvoc " + str(int(tvoc)), color=tvoc_color, font="tom-thumb"),
              render.Text("pm " + str(pm),  color=pm_color, font="tom-thumb"),
              render.Text("etoh " + str(etoh), color=etoh_color, font="tom-thumb"),
              render.Text("Temp " + str(temp) + "f", color=white_color, font="tom-thumb"),
            #  render.Text("iaq " + str(iaq), color=iaq_color, font="tom-thumb")
           ],
        )
    )

                                                              