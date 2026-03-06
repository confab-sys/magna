import 'package:flutter/material.dart';
import 'package:magna_coders/app/theme/colors.dart';
import 'package:magna_coders/app/theme/spacing.dart';
import 'package:magna_coders/app/theme/typography.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// --- MODELS ---

class BuilderSocialLink {
  final String type; // website, github, twitter, whatsapp, linkedin, etc.
  final String label; // display text
  final String url;

  BuilderSocialLink({
    required this.type,
    required this.label,
    required this.url,
  });
}

class BuilderCardData {
  final String id;
  final String name;
  final String? username;
  final String? email;
  final String? avatarUrl;
  final String headline;
  final String? bio;
  final List<String> categories; // e.g. ["AI/ML Engineer", "Backend Developer", "Designer"]
  final List<String> lookingFor; // e.g. ["Frontend Developer", "UI Designer", "Project Manager"]
  final List<String> skills; // e.g. ["Python", "SQL", "TensorFlow", "Dart"]
  final String? location; // e.g. "Nairobi, Kenya"
  final bool isAvailable;
  final List<BuilderSocialLink> socialLinks;

  BuilderCardData({
    required this.id,
    required this.name,
    this.username,
    this.email,
    this.avatarUrl,
    required this.headline,
    this.bio,
    this.categories = const [],
    this.lookingFor = const [],
    this.skills = const [],
    this.location,
    this.isAvailable = true,
    this.socialLinks = const [],
  });
}

// --- MAIN WIDGET ---

class BuilderCard extends StatelessWidget {
  final BuilderCardData builder;
  final VoidCallback? onConnectTap;
  final VoidCallback? onMessageTap;
  final ValueChanged<BuilderSocialLink>? onSocialTap;
  final VoidCallback? onCardTap;

  const BuilderCard({
    super.key,
    required this.builder,
    this.onConnectTap,
    this.onMessageTap,
    this.onSocialTap,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onCardTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Avatar + Info
            _HeaderSection(builder: builder),

            const SizedBox(height: AppSpacing.md),

            // Categories
            if (builder.categories.isNotEmpty) ...[
              _SmartChipList(
                items: builder.categories,
                variant: _ChipVariant.category,
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Looking For
            if (builder.lookingFor.isNotEmpty) ...[
              const _SectionTitle(title: 'Looking for'),
              const SizedBox(height: AppSpacing.xs),
              _SmartChipList(
                items: builder.lookingFor,
                variant: _ChipVariant.lookingFor,
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Skills
            if (builder.skills.isNotEmpty) ...[
              const _SectionTitle(title: 'Skills'),
              const SizedBox(height: AppSpacing.xs),
              _SmartChipList(
                items: builder.skills,
                variant: _ChipVariant.skill,
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Meta info row: Location + Availability
            Row(
              children: [
                if (builder.location != null) ...[
                  PhosphorIcon(
                    PhosphorIcons.mapPin(),
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    builder.location!,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                _AvailabilityBadge(isAvailable: builder.isAvailable),
              ],
            ),

            if (builder.socialLinks.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _SocialLinksSection(
                links: builder.socialLinks,
                onSocialTap: onSocialTap,
              ),
            ],

            const SizedBox(height: AppSpacing.lg),

            // Action Row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConnectTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Connect'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onMessageTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Message'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- HELPER WIDGETS ---

class _HeaderSection extends StatelessWidget {
  final BuilderCardData builder;

  const _HeaderSection({required this.builder});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AvatarView(avatarUrl: builder.avatarUrl, name: builder.name),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                builder.name,
                style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                builder.headline,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvatarView extends StatelessWidget {
  final String? avatarUrl;
  final String name;

  const _AvatarView({this.avatarUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        image: avatarUrl != null
            ? DecorationImage(
                image: NetworkImage(avatarUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: avatarUrl == null
          ? Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: AppTypography.h3.copyWith(color: AppColors.primary),
              ),
            )
          : null,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: AppTypography.bodySmall.copyWith(
        color: AppColors.textSecondary.withOpacity(0.7),
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    );
  }
}

enum _ChipVariant { category, lookingFor, skill }

class _SmartChipList extends StatelessWidget {
  final List<String> items;
  final _ChipVariant variant;

  const _SmartChipList({required this.items, required this.variant});

  @override
  Widget build(BuildContext context) {
    final visibleCount = items.length > 2 ? 2 : items.length;
    final overflowCount = items.length - visibleCount;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...items.take(visibleCount).map((item) => _CustomChip(label: item, variant: variant)),
        if (overflowCount > 0) _OverflowChip(count: overflowCount),
      ],
    );
  }
}

class _CustomChip extends StatelessWidget {
  final String label;
  final _ChipVariant variant;

  const _CustomChip({required this.label, required this.variant});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (variant) {
      case _ChipVariant.category:
        bgColor = AppColors.primary.withOpacity(0.15);
        textColor = AppColors.primary;
        break;
      case _ChipVariant.lookingFor:
        bgColor = Colors.orange.withOpacity(0.15);
        textColor = Colors.orange;
        break;
      case _ChipVariant.skill:
        bgColor = AppColors.border.withOpacity(0.3);
        textColor = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _OverflowChip extends StatelessWidget {
  final int count;

  const _OverflowChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.border.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '+$count',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  final bool isAvailable;

  const _AvailabilityBadge({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (isAvailable ? Colors.green : Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: (isAvailable ? Colors.green : Colors.grey).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isAvailable ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isAvailable ? 'Available' : 'Not Available',
            style: AppTypography.bodySmall.copyWith(
              color: isAvailable ? Colors.green : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialLinksSection extends StatelessWidget {
  final List<BuilderSocialLink> links;
  final ValueChanged<BuilderSocialLink>? onSocialTap;

  const _SocialLinksSection({required this.links, this.onSocialTap});

  @override
  Widget build(BuildContext context) {
    final visibleCount = links.length > 2 ? 2 : links.length;
    final overflowCount = links.length - visibleCount;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        ...links.take(visibleCount).map((link) => _SocialLinkItem(link: link, onTap: onSocialTap)),
        if (overflowCount > 0)
          Text(
            '+$overflowCount more',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
      ],
    );
  }
}

class _SocialLinkItem extends StatelessWidget {
  final BuilderSocialLink link;
  final ValueChanged<BuilderSocialLink>? onTap;

  const _SocialLinkItem({required this.link, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap?.call(link),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getSocialIcon(link.type),
          const SizedBox(width: 4),
          Text(
            link.label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getSocialIcon(String type) {
    IconData iconData;
    switch (type.toLowerCase()) {
      case 'github':
        iconData = PhosphorIcons.githubLogo();
        break;
      case 'twitter':
        iconData = PhosphorIcons.twitterLogo();
        break;
      case 'linkedin':
        iconData = PhosphorIcons.linkedinLogo();
        break;
      case 'whatsapp':
        iconData = PhosphorIcons.whatsappLogo();
        break;
      default:
        iconData = PhosphorIcons.globe();
    }
    return PhosphorIcon(iconData, size: 16, color: AppColors.primary);
  }
}

// --- SAMPLE DATA FOR PREVIEW ---

class BuilderCardDemo extends StatelessWidget {
  const BuilderCardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final sampleBuilder = BuilderCardData(
      id: '1',
      name: 'Alex Magna',
      username: 'alexmagna',
      headline: 'Full-stack Engineer | AI Enthusiast',
      categories: ['AI/ML Engineer', 'Backend Developer', 'Architect'],
      lookingFor: ['Frontend Developer', 'UI Designer', 'Founder'],
      skills: ['Flutter', 'Python', 'Dart', 'Node.js', 'PyTorch'],
      location: 'Nairobi, Kenya',
      isAvailable: true,
      socialLinks: [
        BuilderSocialLink(type: 'github', label: 'GitHub', url: 'https://github.com'),
        BuilderSocialLink(type: 'linkedin', label: 'LinkedIn', url: 'https://linkedin.com'),
        BuilderSocialLink(type: 'twitter', label: 'Twitter', url: 'https://twitter.com'),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.black, // Assuming dark theme context
      appBar: AppBar(title: const Text('Builder Card Demo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BuilderCard(
            builder: sampleBuilder,
            onConnectTap: () => debugPrint('Connect tapped'),
            onMessageTap: () => debugPrint('Message tapped'),
            onSocialTap: (link) => debugPrint('Social tapped: ${link.label}'),
          ),
        ),
      ),
    );
  }
}
