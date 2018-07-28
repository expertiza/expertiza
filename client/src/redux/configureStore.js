import { createStore, combineReducers, applyMiddleware } from 'redux';
import { Profile } from './reducers/Profile';
import studentTaskList from './reducers/StudentTaskList';
import { Institutions } from './reducers/Institution';
import studentTaskView from './reducers/StudentTaskView';
import thunk from 'redux-thunk';
import logger from 'redux-logger';
import authReducer from './reducers/Auth';
import studentTeamView from './reducers/StudentTeamView';

export const ConfigureStore = () => {
    const store = createStore(
        combineReducers({
            profile: Profile,
            studentTaskList: studentTaskList,
            institutions: Institutions,
            studentTaskView:  studentTaskView,
            auth: authReducer,
            studentTeamView: studentTeamView
        }),
        applyMiddleware(thunk, logger)
    );

    return store;
}