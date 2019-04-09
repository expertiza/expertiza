import axios from 'axios';

const instance = axios.create({
    baseURL : 'http://152.46.17.203:3001/api/v1/'
});

export default instance;
