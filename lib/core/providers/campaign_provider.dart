import 'dart:convert';

import 'package:greyfundr/core/api/campaign_api/campaign_api.dart';
import 'package:greyfundr/core/api/auth_api/auth_api.dart';
import 'package:greyfundr/shared/responsiveState/view_state.dart';
import 'package:greyfundr/core/models/participants_model.dart';
import 'package:greyfundr/core/models/campaign_model.dart';
import 'package:greyfundr/services/locator.dart';
import 'package:greyfundr/shared/responsiveState/base_view_model.dart';
import 'package:greyfundr/components/custom_snackbars.dart';

class CampaignProvider extends BaseNotifier {
	final CampaignApi campaignApi = locator<CampaignApi>();
	final AuthApi authApi = locator<AuthApi>();

	List<Participant> users = [];

	Future<List<Participant>> fetchUsers() async {
		setState(ViewState.Busy);
		try {
			users = await campaignApi.getUsers();
			setState(ViewState.DataFetched);
			return users;
		} catch (e) {
			final err = e.toString();
			setError(err);
			showErrorToast(err);
			return [];
		}
	}

	Future<dynamic> createCampaign(Campaign campaign, String userId) async {
		setState(ViewState.Busy);
		try {
			final res = await campaignApi.createCampaignApi(campaign: campaign, userId: userId);
			print('CampaignProvider.createCampaign -> API response: $res');
			setState(ViewState.Success);
			return res;
		} catch (e) {
			final err = e.toString();
			setError(err);
			showErrorToast(err);
			print('CampaignProvider.createCampaign -> error: $err');
			rethrow;
		}
	}

	Future<dynamic> getCampaignApproval(String campaignId) async {
		try {
			final res = await campaignApi.getCampaignApprovalApi(campaignId);
			return res;
		} catch (e) {
			final err = e.toString();
			setError(err);
			showErrorToast(err);
			rethrow;
		}
	}

	/// Helper: get current user profile via AuthApi and return parsed map
	Future<Map<String, dynamic>?> fetchCurrentUserProfile() async {
		try {
			final response = await authApi.userProfileApi();
			if (response is String) {
				return jsonDecode(response) as Map<String, dynamic>?;
			}
			if (response is Map<String, dynamic>) return response;
			return null;
		} catch (e) {
			final err = e.toString();
			setError(err);
			showErrorToast(err);
			return null;
		}
	}
}