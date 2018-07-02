import { createStore, combineReducers, applyMiddleware } from 'redux';
import { Profile } from './Profile';
import thunk from 'redux-thunk';
import logger from 'redux-logger';

export const ConfigureStore = () => {
    const store = createStore(
        combineReducers({
            profile: Profile
        }),
        applyMiddleware(thunk, logger)
    );

    return store;
}