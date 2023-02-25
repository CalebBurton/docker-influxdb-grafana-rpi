import pandas as pd
from influxdb import InfluxDBClient

client = InfluxDBClient(
            host='1.1.1.1',
            port=8086,
            username='', # config/influxdb/influxdb.env --> DOCKER_INFLUXDB_INIT_USERNAME
            password='', # config/influxdb/influxdb.env --> DOCKER_INFLUXDB_INIT_PASSWORD
            database='home_assistant',
            ssl=False,
            verify_ssl=False
        )

file_path = r'/Users/user/Downloads/states.csv'

csvReader = pd.read_csv(file_path)

print(f'Input shape (rows, columns): {csvReader.shape}')
print(f'Input column names: {csvReader.columns}')

for row_index, row in csvReader.iterrows() :
    timestamp = pd.to_datetime(row[0], unit='s')
    state = row[1]
    print(f'Row {row_index:04}:\t{timestamp}\t{state}')

    # It will probably take some trial and error to determine which data points
    # are "tags" and which are "fields", so make sure to do some test runs.
    json_body = [{
        "time": timestamp,
        "measurement": "°F",
        "tags": {
            "domain": "sensor",
            "entity_id": "lumi_lumi_weather_temperature",
            "source": "hass",
        },
        "fields": {
            "device_class_str": "temperature",
            "friendly_name_str": "Aqara Temperature Sensor",
            "state_class_str": "measurement",
            "value": state,
        }
    }]
    client.write_points(json_body)
    # break
# result = client.query('select * from "°F" WHERE time > 1676840000000000000 limit 1;')
# print(f"Result: {result}")

# Some helpful influx commands:
# use home_assistant
# select * from "°F" WHERE time > 1676840000000000000 AND time < 1676849359301970000 limit 10
# delete from "°F" WHERE time = 1676849359000000000
