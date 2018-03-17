import { Deployer } from '@0xproject/deployer';
import { BigNumber } from '@0xproject/utils';
import { Web3Wrapper } from '@0xproject/web3-wrapper';
import * as _ from 'lodash';

import { constants } from '../util/constants';
import { ContractName } from '../util/types';

import { tokenInfo } from './config/token_info';

/**
 * Custom migrations should be defined in this function. This will be called with the CLI 'migrate' command.
 * Migrations could be written to run in parallel, but if you want contract addresses to be created deterministically,
 * the migration should be written to run synchronously.
 * @param deployer Deployer instance.
 */
export const runMigrationsAsync = async (deployer: Deployer) => {
    const web3Wrapper: Web3Wrapper = deployer.web3Wrapper;
    const accounts: string[] = await web3Wrapper.getAvailableAddressesAsync();

    const State = await deployer.deployAndSaveAsync(ContractName.State);
};
