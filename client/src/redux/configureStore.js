import { createStore, combineReducers, applyMiddleware } from 'redux';
import { Profile } from './Profile';
import { Institutions } from './Institution';
import { createForms } from 'react-redux-form';
import { Profileform } from './profileform';
import thunk from 'redux-thunk';
import logger from 'redux-logger';
import authReducer from './reducers/Auth';

export const ConfigureStore = () => {
    const store = createStore(
        combineReducers({
            profile: Profile,
            institutions: Institutions,
            ...createForms({
                profileForm: Profileform
            }),
            auth: authReducer
        }),
        applyMiddleware(thunk, logger)
    );

    return store;
}