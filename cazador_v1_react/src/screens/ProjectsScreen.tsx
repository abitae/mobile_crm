import React from 'react';
import { View, Text, ScrollView, StyleSheet } from 'react-native';
import { Briefcase, CheckCircle2, Clock } from 'lucide-react-native';
import { colors, spacing, borderRadius } from '../theme';
import type { Project } from '../types';

interface ProjectsScreenProps {
  projects: Project[];
}

export function ProjectsScreen({ projects }: ProjectsScreenProps) {
  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <Text style={styles.title}>Proyectos Inmobiliarios</Text>
      {projects.map((project) => (
        <View key={project.id} style={styles.card}>
          <View style={styles.cardHeader}>
            <View style={styles.cardTitleRow}>
              <View style={styles.iconWrap}>
                <Briefcase size={18} color={colors.zinc[400]} />
              </View>
              <View>
                <Text style={styles.cardTitle}>{project.title}</Text>
                <Text style={styles.cardLocation}>{project.location}</Text>
              </View>
            </View>
            {project.status === 'completed' ? (
              <CheckCircle2 size={18} color={colors.emerald[500]} />
            ) : (
              <Clock size={18} color={colors.blue[500]} />
            )}
          </View>
          <View style={styles.statsRow}>
            <View style={styles.stat}>
              <Text style={styles.statLabel}>Unidades</Text>
              <Text style={styles.statValue}>{project.units}</Text>
            </View>
            <View style={styles.stat}>
              <Text style={styles.statLabel}>Progreso</Text>
              <Text style={styles.statValue}>{project.progress}%</Text>
            </View>
          </View>
          <View style={styles.progressBar}>
            <View
              style={[
                styles.progressFill,
                {
                  width: `${project.progress}%`,
                  backgroundColor: project.status === 'completed' ? colors.emerald[500] : colors.blue[500],
                },
              ]}
            />
          </View>
        </View>
      ))}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  content: { padding: spacing.lg, gap: spacing.md },
  title: { fontSize: 20, fontWeight: '700', color: colors.zinc[900], marginBottom: spacing.sm },
  card: {
    backgroundColor: colors.white,
    padding: spacing.lg,
    borderRadius: borderRadius.xl,
    borderWidth: 1,
    borderColor: colors.zinc[100],
    gap: spacing.md,
  },
  cardHeader: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  cardTitleRow: { flexDirection: 'row', alignItems: 'center', gap: spacing.md },
  iconWrap: {
    width: 36,
    height: 36,
    borderRadius: borderRadius.xl,
    backgroundColor: colors.zinc[50],
    alignItems: 'center',
    justifyContent: 'center',
  },
  cardTitle: { fontSize: 12, fontWeight: '700', color: colors.zinc[900] },
  cardLocation: { fontSize: 10, color: colors.zinc[400] },
  statsRow: { flexDirection: 'row', gap: spacing.sm },
  stat: { flex: 1, backgroundColor: colors.zinc[50], padding: spacing.sm, borderRadius: borderRadius.sm },
  statLabel: { fontSize: 8, fontWeight: '700', color: colors.zinc[400] },
  statValue: { fontSize: 12, fontWeight: '700', color: colors.zinc[900] },
  progressBar: { height: 6, backgroundColor: colors.zinc[50], borderRadius: borderRadius.full, overflow: 'hidden' },
  progressFill: { height: '100%', borderRadius: borderRadius.full },
});
