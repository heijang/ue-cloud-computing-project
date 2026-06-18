import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  vus: 10,       // 10 Virtual Users
  duration: '10s', // sustain load concurrently for 10 seconds
};

export default function () {
  http.get('https://google.com'); // target URL under test
  sleep(1);
}