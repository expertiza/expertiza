import { createStore, combineReducers, applyMiddleware } from 'redux';
import { Profile } from './Profile';
import { StudentsTeamedWith } from './StudentsTeamedWith'
import { studentTasks } from './StudentTasks'
import { Institutions } from './Institution';
import { createForms } from 'react-redux-form';
import { Profileform } from './profileform';
import thunk from 'redux-thunk';
import logger from 'redux-logger';

export const ConfigureStore = () => {
    const store = createStore(
        combineReducers({
            profile: Profile,
            studentsTeamedWith: StudentsTeamedWith,
            studentTasks: studentTasks,
            institutions: Institutions,
            ...createForms({
                profileForm: Profileform
            })
        }),
        applyMiddleware(thunk, logger)
    );

    return store;
}